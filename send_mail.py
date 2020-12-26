################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######
######
######	Hydroxide SMTP Server Link
######
######
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# Python code for send encrypted protonmail via hydroxide smtp server link.


################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######  Dependencies
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# REQUIRED: Hydroxide, follow readme instructions for setup

from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders						# for attaching files
import smtplib									# for sending email

import os										# for changing the path
import json										# for loading the hydroxide user data


################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######  Procedure
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


def send(sender, receiver, subject, message, **kwargs):

	'''

	Python function for sending a message

	See: https://stackoverflow.com/questions/56330521/sending-an-email-with-python-from-a-protonmail-account-smtp-library


	'''

	# server information

	port_number = 1025
	smtpaddr = 'localhost'
	account, password = accountpass()
	
	bcc = kwargs.get('bcc',[])					# get receipients, if passed to function
	bcc = [bcc] if bcc != [] else []

	receipients = [ receiver ]
	receipients.extend(bcc)

	# prepare message programmatically 
	
	msg = MIMEMultipart()
	msg['From'] = sender 
	msg['To'] = receiver						# receiver provided to function
	msg['Subject'] = subject					# subject  ''  ''
	msg.attach(MIMEText(message, 'html'))		# message  ''  ''

	if len(receipients) > 1:
		msg['BCC'] = bcc[0]

	# send message

	mailserver = smtplib.SMTP(smtpaddr,port_number)
	mailserver.login(account, password)
	mailserver.sendmail(sender, receipients, msg.as_string())
	mailserver.quit()


def accountpass():

	'''

	Returns two variables (account, password) that are stored in /opt/hydroxide-container/data-hydroxide 


	This has to be loaded on each call, as the hydroxide container will change its auth variables on each restart

	'''

	home = os.getcwd()

	os.chdir('/opt/hydroxide-container/data-hydroxide')

	with open('auth.json') as json_file:
		data = json.load(json_file)

	os.chdir(home)

	return data['user'], data['hash']


def example():

	# TODO update the first two strings (sender, receiver) in the below function call

	send('sender@yourwebsite.com','receiver@anotherwebsite.com','Test message','This is a test message to verify that this script is working accordingly.')


if __name__ == '__main__':

	'''

	Run the example script when called directly.

	'''

	example()


