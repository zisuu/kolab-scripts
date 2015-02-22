#!/bin/sh

echo "Please enter new domain name (example: mydomain.ch)  :"
read domainname

echo "\n
\n
[$domainname]
default_quota = 1048576
policy_uid = %(givenname)s.%(surname)s@%(domain)s
primary_mail = %(givenname)s.%(surname)s@%(domain)s
secondary_mail = {
        0: {
        \"{0}.{1}@{2}\": \"format('%(givenname)s'[0:1].capitalize(), '%(surname)s', '%(domain)s')\"
        }
        }
autocreate_folders = {
        'Archive': {
        'quota': 0,
        'partition': 'archive'
        },
        'Calendar': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"event.default\",
        '/shared/vendor/kolab/folder-type': \"event\",
        },
        },
        'Calendar/Personal Calendar': {
        'annotations': {
        '/shared/vendor/kolab/folder-type': \"event\",
        },
        },
        'Configuration': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"configuration.default\",
        '/shared/vendor/kolab/folder-type': \"configuration.default\",
        },
        },
        'Contacts': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"contact.default\",
        '/shared/vendor/kolab/folder-type': \"contact\",
        },
        },
        'Contacts/Personal Contacts': {
        'annotations': {
        '/shared/vendor/kolab/folder-type': \"contact\",
        },
        },
        'Drafts': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"mail.drafts\",
        },
        },
        'Files': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"file.default\",
        },
        },
        'Journal': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"journal.default\",
        '/shared/vendor/kolab/folder-type': \"journal\",
        },
        },
        'Notes': {
        'annotations': {
        '/private/vendor/kolab/folder-type': 'note.default',
        '/shared/vendor/kolab/folder-type': 'note',
        },
        },
        'Sent': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"mail.sentitems\",
        },
        },
        'Spam': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"mail.junkemail\",
        },
        },
        'Tasks': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"task.default\",
        '/shared/vendor/kolab/folder-type': \"task\",
        },
        },
        'Trash': {
        'annotations': {
        '/private/vendor/kolab/folder-type': \"mail.wastebasket\",
        },
        },
        }" >> /etc/kolab/kolab.conf
echo "New Domain $domainname successfully added to /etc/kolab/kolab.conf"