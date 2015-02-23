#!/bin/bash

echo 'Please enter new domain name (example: dc=mydomain,dc=com)  :'
read domainname

echo 'Please enter number of existing domains in owncloud (example three domains: S03), example five domains: S05  :'
read domainid

has_memberof_filter_support='has_memberof_filter_support'
home_folder_naming_rule='home_folder_naming_rule'
last_jpegPhoto_lookup='last_jpegPhoto_lookup'
ldap_agent_password='ldap_agent_password'
ldap_attributes_for_group_search='ldap_attributes_for_group_search'
ldap_attributes_for_user_search='ldap_attributes_for_user_search'
ldap_backup_host='ldap_backup_host'
ldap_backup_port='ldap_backup_port'
ldap_base='ldap_base'
ldap_base_groups='ldap_base_groups'
ldap_cache_ttl='ldap_cache_ttl'
ldap_configuration_active='ldap_configuration_active'
ldap_display_name='ldap_display_name'
ldap_dn='ldap_dn'
ldap_email_attr='ldap_email_attr'
ldap_experienced_admin='ldap_experienced_admin'
ldap_expert_username_attr='ldap_expert_username_attr'
ldap_expert_uuid_group_attr='ldap_expert_uuid_group_attr'
ldap_expert_uuid_user_attr='ldap_expert_uuid_user_attr'
ldap_group_display_name='ldap_group_display_name'
ldap_group_filter='ldap_group_filter'
ldap_group_filter_mode=''
ldap_group_member_assoc_attribute=''
ldap_groupfilter_groups=''
ldap_groupfilter_objectclass=''
ldap_host=''
ldap_login_filter_mode=''
ldap_loginfilter_attributes=''
ldap_loginfilter_email=''
ldap_loginfilter_username=''
ldap_nested_groups=''
ldap_nocase=''
ldap_override_main_server=''
ldap_paging_size=''
ldap_port=''
ldap_quota_attr=''
ldap_quota_def=''
ldap_tls=''
ldap_turn_off_cert_check=''
ldap_user_filter_mode=''
ldap_userfilter_groups=''
ldap_userfilter_objectclass=''
ldap_userlist_filter=''

mysql --host=localhost --user=root --password=enter your password owncloud_db << EOF
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}has_memberof_filter_support','0');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${home_folder_naming_rule}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${last_jpegPhoto_lookup}','0');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_agent_password}','NFRoYUBjbGRNYXN0ZXI=');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_attributes_for_group_search}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_attributes_for_user_search}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_backup_host}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_backup_port}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_base}','$domainname');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_base_groups}','$domainname');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_base_users}','$domainname');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_cache_ttl}','600');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_configuration_active}','1');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_display_name}','displayname');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_dn}','cn=Directory Manager');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_email_attr}','mail');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_experienced_admin}','1');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_expert_username_attr}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_expert_uuid_group_attr}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_expert_uuid_user_attr}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_group_display_name}','cn');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_group_filter}','(|(objectclass=groupofuniquenames)(objectclass=groupofurls))');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_group_filter_mode}','1');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_group_member_assoc_attribute}','uniqueMember');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_groupfilter_groups}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_groupfilter_objectclass}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_host}','192.168.31.75');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_login_filter_mode}','1');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_loginfilter_attributes}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_loginfilter_email}','0');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_loginfilter_username}','1');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_nested_groups}','0');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_nocase}','0');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_override_main_server}','0');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_paging_size}','500');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_port}','389');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_quota_attr}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_quota_def}','1024');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_tls}','1');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_turn_off_cert_check}','0');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_user_filter_mode}','1');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_userfilter_groups}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_userfilter_objectclass}','');
insert into oc_appconfig (appid,configkey,configvalue) values('user_ldap','${domainid}${ldap_userlist_filter}','(|(objectclass=inetorgperson))');

EOF


