'''
Title:  disk_space_checker
Desc:   Check available disk space & notifiy if it's less than a threshold
Author: Yassin Eltahir
Date:   2017-02-16
'''

import psutil
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText


# Get All Available Drives
drives = [x[0] for x in psutil.disk_partitions()]

# What's the maximum % of disk space to be consumed before sending an alert
threshold = 0.5

# For each drive, test if sufficient space is available
for drive in drives:
    
    pct_remaining = psutil.disk_usage(drive)[3]/100

    if pct_remaining > threshold:
        
        # Create Email Text
        to_notify = 'example@example.com'
        subject = 'Drive {} is {} full'.format(drive*100.0, pct_remaining)
        body = 'Might be time to do something about this.....'
        
        # Send Email
        print subject
        print "Sending email..."
        send_email(to_notify, subject, body)
        print ""



# Function to Send Email
def send_email(recipients, subject, body):

    # Source Sender details
    sender_adr = 'example@example.com'
    sender_pw = 'Your Password'

    # Setup Connection
    try:
        econ = smtplib.SMTP('smtp-mail.outlook.com', 587) # Obviously this would need to change according to the email address used
        econ.ehlo()
        econ.starttls()
        econ.login(sender_adr, sender_pw)
        print "Connection Established"
    except:
        print "Something went wrong ...."
    
    # Prepare Recipients
    if isinstance(recipients, list):
        recipients = ';'.join(recipients)

    # Build Message
    msg = MIMEMultipart()
    msg['From'] = sender_adr
    msg['To'] = recipients
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    msg = msg.as_string()


    # Send email & Close connection
    try:
        econ.sendmail(sender_adr, recipients, msg)
        econ.quit()
        print "Email sent"
    except:
        print "Something went wrong ...."


