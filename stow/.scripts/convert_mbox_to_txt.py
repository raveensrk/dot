#!/usr/bin/env python3

import email.message
import mailbox

# Just ignore these lines.
# Python's mbox reader finds a way to return Messages that don't
# have these super-important methods. This hack adds them.
setattr(email.message.Message, '_find_body', email.message.MIMEPart._find_body)
setattr(email.message.Message, '_body_types', email.message.MIMEPart._body_types)
setattr(email.message.Message, 'get_body', email.message.MIMEPart.get_body)
setattr(email.message.Message, 'is_attachment', email.message.MIMEPart.is_attachment)
setattr(email.message.Message, 'iter_parts', email.message.MIMEPart.iter_parts)
setattr(email.message.Message, 'iter_attachments', email.message.MIMEPart.iter_attachments)

# Reads an mbox from a file and returns a list of messages.
def read_mbox(filename):
    mbox = mailbox.mbox(filename)
    return mbox.values()

# Returns some text describing a message. Headers at the top, then
# two newlines, then message body as text.
def message_to_text(message):
    metadata = """From: {}
To: {}
Cc: {}
Date: {}
Subject: {}""".format(message['From'], message['To'], message['Cc'], message['Date'], message['Subject'])

    attachment_filenames = message_attachment_filenames(message)
    if len(attachment_filenames) > 0:
        metadata += ('\nAttached: %s' % ', '.join(attachment_filenames))

    try:
        body_part = message.get_body(('plain',))
        charset = body_part.get_content_charset() or message.get_content_charset() or 'utf-8'
        body = body_part.get_payload(decode=True).decode(charset)
    except AttributeError as err:
        body = '<could not read message: %s>' % str(err)

    return metadata + '\n\n' + body

# True IFF the given attachment is worth mentioning.
#
# Some attachments (such as Outlook-related files) aren't worth mentioning.
def is_valid_attachment(mime_part):
    return mime_part.get_content_type() not in (
            'text/plain',
            'application/ms-tnef',
            'message/delivery-status',
            'text/rfc822-headers',
    ) and mime_part.get_filename() is not None

# Returns a list of attachments worth mentioning in the given message.
def message_to_attachments(message):
    return [ a for a in message.iter_attachments() if is_valid_attachment(a) ]

# Returns the filenames for all attachments worth mentioning in the given message.
def message_attachment_filenames(message):
    return [ a.get_filename() for a in message_to_attachments(message) ]

# Converts a filename into something that can be saved on the filesystem.
#
# In other words: replaces "/" with "_".
def simplify_filename(filename):
    return filename.replace('/', '_')

# Writes a message to a file in the current working directory.
#
# Also writes any attachments that were attached, with the filename they had
# in the email.
def write_message(message, i):
    for attachment in message_to_attachments(message):
        with open(simplify_filename(attachment.get_filename()), 'wb') as f:
            f.write(attachment.get_payload(decode=True))

    with open(simplify_filename('%s [%d].txt' % (message['Subject'], i)), 'w') as f:
        f.write(message_to_text(message))

# Reads the given mbox file and outputs all messages and attachments
# as files in the current working directory.
def main(filename):
    messages = read_mbox(filename)
    for i, message in enumerate(messages):
        write_message(message, i + 1)

if __name__ == '__main__':
    import sys
    filename = sys.argv[1]
    main(filename)

