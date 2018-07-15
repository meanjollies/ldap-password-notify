#!/usr/bin/env ruby

# Title:  ldap-password-notify.rb
# Descr:  Check the expiration status of users' paswords in LDAP. An email notification will be sent
#         out in the event a user's password will soon or has expired.
# Author: Andrew O'Neill
# Date:   2018

$LOAD_PATH.unshift __dir__ + '/lib'

require 'logger'
require 'yaml'
require 'audit'

config = YAML.load_file(File.dirname(File.expand_path(__FILE__)) + '/conf/config.yaml')

logger = Logger.new('ldap-password-notify.log', 7)

directory = Audit.new(logger)

directory.blacklist = config['blacklist']
directory.thresh = config['exp_thresh']
directory.bind_user = config['ldap']['username']
directory.bind_pass = config['ldap']['password']
directory.hostname = config['ldap']['hostname']
directory.port = config['ldap']['port']
directory.basedn = config['ldap']['treebase']
directory.sender = config['sender']

directory.connect
directory.audit
