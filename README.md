# ldap-password-notify

Check the expiration status of accounts' paswords in LDAP. This was developed and tested using my [389DS container](https://github.com/meanjollies/docker-images/tree/master/389-ds).

### Configuration

All LDAP accounts that are being checked are expected to contain the following attributes: `uid`, `mail`, `givenName`, and `passwordExpirationTime`.

Prior to running, make sure `conf/config.yaml` is filled out. All parameters, except `blacklist`, are required.
* `exp_thresh`: This is the number of days left (aka threshold) before an account's password expires, wherein its email address will start receiving notifications.
* `sender`: This is the desired email address that notifications will appear to come from.
* `blacklist`: A list of account UIDs that should be ignored. This might include any API accounts with non-expiring passwords, or accounts that lack the required attributes to perform a successful check. This is optional.
* `ldap`
  * `hostname`: The hostname or IP address to connect to.
  * `port`: The port the LDAP server is listening on.
  * `username`: The binding LDAP account username. This must have the ability to read the password expiration attribute.
  * `password`: The binding LDAP account password.
  * `treebase`: The base DN where accounts reside.

If any errors are encountered during an account's check, such as a missing required attribute, the audit will continue onto the next account.

Logging is enabled by default with a rotation of 7 days, and is stored in the working directory from which `ldap-password-notify.rb` is run. Although its location and rotation time are not currently present in `config.yaml`, you can change that setup in `ldap-password-notify.rb`.

There are two email templates under `conf/` that can be edited to your liking: `expired.erb` will be used for notifying accounts of their expired passwords, and `warn.erb` will be used for notifying accounts whose passwords have fallen within the warning threshold. SMTP is currently not configurable; notificants will attempted to be sent out using your local MTA.

### Usage

`$ ./ldap-password-notify.rb`

It is recommended that this be used as part of a cronjob. It can be called from anywhere, although you should make sure an appropriate logging location is set.

### To Do

* Dry runs
* Verbosity. Currently, nothing is displayed in stdout, as everything gets sent to the log.
* Allow for the configuration of the expiry attribute. Currently, `passwordExpirationTime` is used.

License
---
MIT
