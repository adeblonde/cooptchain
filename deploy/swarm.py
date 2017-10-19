import python_terraform as Terraform
import argparse
import ansible
import threading
import subprocess as sub
import Queue
import time
import sys
import os
import json
import shlex

NB_TASKS_MAX = 10000

exitFlag = 0

queueLock = threading.Lock()
taskQueue = Queue.Queue(NB_TASKS_MAX)

def clean_ssh_key(ip_host):

	args = shlex.split('ssh-keygen -R %s ' % ip_host)
	p = sub.Popen(args, stdout=sub.PIPE)
	#print(p)
	#if p.returncode != 0 :
	#	raise Exception("Error cleaning previous SSH certificate for IP %s " % ip_host)

def add_ssh_key_for_host(ip_host):
	args = shlex.split('ssh-keyscan -H %s ' % ip_host)
	p = sub.Popen(args, stdout=sub.PIPE)
	stdout = p.communicate()[0]
	print(ip_host)
	if p.returncode != 0 :
		print("error")
		raise Exception("Error adding IP %s to accepted SSH certificates" % ip_host)
	#print(stdout.strip())
	return stdout.strip()

class taskThread(threading.Thread):
	def __init__(self, threadID, task_name,
			  host_number, work_dir, queue, log_file, ssh_key):
		threading.Thread.__init__(self)
		self.threadID = threadID
		self.task_name = task_name
		self.host_number = host_number
		self.work_dir = work_dir
		self.queue = queue
		self.log = log_file
		self.ssh_key = ssh_key
	
	def run(self):
		print "Starting " + str(self.threadID)
		while not exitFlag :
			queueLock.acquire()
			if not taskQueue.empty():
				task_specs = taskQueue.get()
				queueLock.release()
				instance_task(self.task_name, 
				  self.host_number, self.work_dir, 
				  task_specs['playbook_file'],
				  task_specs['subtask_name'], self.log, self.ssh_key)
			else:
				print("empty queue")
				queueLock.release()
				break
			time.sleep(1)
		print "Exiting " + str(self.threadID)

def instance_task(task_name, host_number, work_dir, playbook_path, subtask_name, log_file, ssh_key):

	print("debug : /usr/local/bin/ansible-playbook -i %s/host_%s_%s.ini -u ec2-user %s --private-key=%s " % (work_dir, task_name, host_number, playbook_path, ssh_key))
	with open(work_dir + "/" + log_file,"a") as file:
		file.write("Begin task %s on host %s \n" % (task_name, host_number))
	sub.call(["/usr/local/bin/ansible-playbook","-i","%s/host_%s_%s.ini" % (work_dir, task_name, host_number),"-u", "ec2-user", playbook_path, "--private-key=%s" % ssh_key])
	with open(work_dir + "/" + log_file,"a") as file:
		file.write("Finished task %s on host %s \n" % (task_name, host_number))
	time.sleep(1)

	print("subprocess %s of task %s on host %s ended" % (subtask_name, task_name, host_number))

def global_task(task_name, work_dir, playbook_path, subtask_name, log_file, ssh_key):

	print("debug : /usr/local/bin/ansible-playbook -i %s/host_%s.ini -u ec2-user %s --private-key=%s " % (work_dir, task_name, playbook_path, ssh_key))
	with open(work_dir + "/" + log_file,"a") as file:
		file.write("Begin task %s on all hosts \n" % (task_name))
	sub.call(["/usr/local/bin/ansible-playbook","-i","%s/host_%s.ini" % (work_dir, task_name),"-u", "ec2-user", playbook_path, "--private-key=%s" % ssh_key])
	with open(work_dir + "/" + log_file,"a") as file:
		file.write("Finished task %s on all hosts \n" % (task_name))
	time.sleep(1)

	print("subprocess %s of task %s on all hosts ended" % (subtask_name, task_name))


def main() :
	"""
	Launch a distributed task with VMs
	"""
	parser = argparse.ArgumentParser(description='This script launch a distributed task on VMs on the cloud or on bare metal')
	parser.add_argument('--terraform-file',
					 help='configuration file for instances to launch (YAML format)', 
					 dest='terraform_file')
	parser.add_argument('--task-file',
					 help='list of tasks to process (YAML format)', 
					 dest='tasks_list')
	parser.add_argument('--working-folder',
					 help='working folder where terraform.tfstate will be stored',
					 dest='work_folder', default='.')
	parser.add_argument('--task-name',
					 help='name of global task to proceed',
					 dest='task_name', default='datascience_task')
	parser.add_argument('--log-file',
					 help='name of log file into work dir',
					 dest='log_file', default='log.txt')
	parser.add_argument('--ssh-key',
					 help='location of the private SSH key (.pem file)', 
					 dest='ssh_key', default=None)

	args = parser.parse_args()
	
	
	# get and apply terraform file
	tf_file = args.terraform_file
	work_dir = args.work_folder
	task_name = args.task_name
	log_file = args.log_file
	task_file = args.tasks_list
	ssh_key = args.ssh_key

	tfstate_name = work_dir + '/' + task_name + '.tfstate'

	tf = Terraform.Terraform(state=work_dir + '/' + task_name + '.tfstate')
	print tf.plan(work_dir, out=work_dir + '/' + task_name + '.out',refresh=True,no_color=Terraform.IsFlagged, state=work_dir + '/' + task_name + '.tfstate')
	print tf.apply(work_dir, state=work_dir + '/' + task_name + '.tfstate',refresh=True,no_color=Terraform.IsFlagged)
	
	print("waiting for everyone to be launched")
	time.sleep(10)

	with open(tfstate_name) as f:
		tfstate = json.load(f)

	hosts_list = tfstate['modules'][0]
	hosts_list = hosts_list['resources']
	hosts_attributes = []

	# get list of hosts attributes
	for instance in hosts_list:
		hosts_attributes.append(hosts_list[instance]['primary']['attributes'])

	# create all hosts file
	nb_hosts = len(hosts_attributes)
	with open("%s/host_%s.ini" % (work_dir, task_name),"w") as file :
		file.write('[task_'+task_name+']\n')
		instance_counter=1
		for host in hosts_attributes :
			file.write('ds_instance_%s ansible_ssh_host=%s \n' % (instance_counter, host['public_ip']))
			instance_counter+=1

	# create hosts files by group + specific host files with group name
	nb_host = 0
	for host in hosts_attributes :
		nb_hosts+=1

	instance_counter=1
	for host in hosts_attributes :
		# create an all hosts file
		with open("%s/host_%s_%s.ini" % (work_dir, host['tags.Group'], task_name),"w") as file :
			file.write('[task_' + task_name + '_' + host['tags.Group'] + ']\n')
		instance_counter+=1
	instance_counter=1
	for host in hosts_attributes :
		# create an all hosts file
		with open("%s/host_%s_%s.ini" % (work_dir, host['tags.Group'], task_name),"a") as file :
			file.write('ds_instance_%s ansible_ssh_host=%s \n' % (instance_counter, host['public_ip']))
		instance_counter+=1
	instance_counter=1
	for host in hosts_attributes :
		# create one file per host
		with open("%s/host_%s_%s_%s.ini" % (work_dir, host['tags.Group'], task_name, instance_counter),"w") as file :
			file.write('[task_' + task_name + '_' + host['tags.Group'] + ']\n')
			file.write('ds_instance_%s ansible_ssh_host=%s \n' % (instance_counter, host['public_ip']))
		instance_counter+=1

	### create specific host file + associated thread
	threads_list = []
	host_counter=1
	for host in hosts_attributes :
		with open("%s/host_%s_%s.ini" % (work_dir, task_name, host_counter),"w") as file :
			file.write('[task_'+task_name+']\n')
			file.write('ds_instance_%s ansible_ssh_host=%s \n' % (host_counter, host['public_ip']))
		thread = taskThread(host_counter, task_name, host_counter, work_dir, taskQueue, log_file, ssh_key)
		threads_list.append(thread)
		host_counter+=1

	### add IPs to list of accepted SSH certificates
	add_linebreak = False

	ssh_directory = os.getenv("HOME") + '/.ssh'
	ssh_known_hosts_file = os.getenv("HOME") + '/.ssh/known_hosts'
	if not (os.path.exists(ssh_directory)) :
		os.makedirs(ssh_directory)
	if (os.path.exists(ssh_known_hosts_file)) :
		with open(ssh_known_hosts_file,'r') as file:
			lines = file.read()
			for line in lines.split('\n') :
				if line != "" :
					add_linebreak = False
					break
	  

	#for host in hosts_attributes :
		#clean_ssh_key(host['public_ip'])

	print("adding SSH certificate")
	with open(os.getenv("HOME") + "/.ssh/known_hosts","a") as file:
		if add_linebreak :
			file.write('\n')
		for host in hosts_attributes :
			#clean_ssh_key(host['public_ip'])
			line = add_ssh_key_for_host(host['public_ip'])
			file.write(line + '\n')

	### fill task Queue + global tasks list
	global_tasks_list=[]
	queueLock.acquire()
	task_id = 1
	with open(task_file,"r") as file :
		lines = file.read()
		#print(lines)
		for line in lines.split('\n') :
			if line != "" :
				#print line
				task_specs = {}
				elts = line.split('\t')
				if ((len(elts) > 1) & (str(elts[2]) != "-1")) :
					task_specs.update({"subtask_name" : elts[0]})
					task_specs.update({"playbook_file" : elts[1]})
					task_specs.update({"task_id" : task_id})
					taskQueue.put(task_specs)
				if ((len(elts) > 1) & (str(elts[2]) == "-1")) :
					global_tasks_list.append([elts[0],elts[1]])
	queueLock.release()

	### launch global tasks
	with open(work_dir + "/" + log_file,"w") as file:
		file.write("Launching global tasks %s with %s hosts \n" % (task_name, host_counter))
		for task in global_tasks_list :
			global_task(task_name, work_dir, task[1], task[0], log_file, ssh_key)

	### launch threads
	if not taskQueue.empty() :
		#print(work_dir + "/" + log_file)
		with open(work_dir + "/" + log_file,"w") as file:
			file.write("Launching task %s with %s hosts \n" % (task_name, host_counter))
		for t in threads_list :
			t.start()

		# Wait for queue to empty
		while not taskQueue.empty():
			pass
		print "Empty queue"
		# Notify threads it's time to exit
		exitFlag = 1

		# Wait for all threads to complete
		for t in threads_list :
			t.join()
		print "Closing all threads"

		with open(work_dir + "/" + log_file,"a") as file:
			file.write("Finished task %s with %s hosts \n" % (task_name, host_counter))

main()