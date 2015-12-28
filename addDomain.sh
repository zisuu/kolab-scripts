#!/bin/bash

echo '********** Please enter new domain name (example: dc=mydomain,dc=com)  :'
read domainname


####### OWNCLOUD PART #######
# count existing domains in Owncloud
user="root"
password="yourpassword"
dbname="youOCdatabase"

QUERY=$(echo "select configkey from oc_appconfig where configvalue='cn=Directory Manager';" | mysql -u $user -p$password $dbname | grep -o ldap | wc -l)
RESULT=${QUERY}

echo '********** Please check the number of existing domains, is '${RESULT}' existing domains correct?  [y/n] :'
read answere

# define Variables
ldappwd="yourLDAPpassword" 
ldaphostip="yourLDAPhostIP"

if [ "${answere}" != "y" ]
then
    echo 'exit script because you did not agree the number of existing domains'
    exit 0
else
        count=${#RESULT}
        if [ "${count}" -eq "1" ]
        then
                domainid="S0${RESULT}"

        else
                domainid="S${RESULT}"
        fi

	mysql --user=$user --password=$password $dbname << EOF
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}has_memberof_filter_support','0');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}home_folder_naming_rule','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}last_jpegPhoto_lookup','0');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_agent_password','$ldappwd');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_attributes_for_group_search','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_attributes_for_user_search','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_backup_host','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_backup_port','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_base','$domainname');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_base_groups','$domainname');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_base_users','$domainname');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_cache_ttl','600');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_configuration_active','1');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_display_name','displayname');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_dn','cn=Directory Manager');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_email_attr','mail');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_experienced_admin','1');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_expert_username_attr','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_expert_uuid_group_attr','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_expert_uuid_user_attr','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_group_display_name','cn');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_group_filter','(|(objectclass=groupofuniquenames)(objectclass=groupofurls))');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_group_filter_mode','1');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_group_member_assoc_attribute','uniqueMember');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_groupfilter_groups','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_groupfilter_objectclass','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_host','$ldaphostip');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_login_filter','(&(|(objectclass=inetorgperson))(|(uid=%uid)(|(givenName=%uid))))');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_login_filter_mode','1');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_loginfilter_attributes','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_loginfilter_email','0');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_loginfilter_username','1');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_nested_groups','0');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_nocase','0');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_override_main_server','0');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_paging_size','500');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_port','389');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_quota_attr','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_quota_def','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_tls','1');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_turn_off_cert_check','0');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_user_filter_mode','1');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_userfilter_groups','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_userfilter_objectclass','');
	insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}ldap_userlist_filter','(|(objectclass=inetorgperson))');

EOF

echo "********** SQL Querys done - new Domain successfully added to owncloud **********"
fi

####### KOLAB PART #######


str1=$(echo $domainname  | sed -e 's/,.*//g' | sed 's/\dc=//g')
str2=$(echo $domainname  | sed 's/^.*,//' | sed 's/\dc=//g')
strkolab=$str1.$str2

echo "\n
\n
[$strkolab]
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
        }" | ssh root@$ldaphostip "cat >> /etc/kolab/kolab.conf"
echo "********** New Domain $strkolab successfully added to /etc/kolab/kolab.conf on $ldaphostip"
