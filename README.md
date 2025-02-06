# PolicyManager
A policy manager using Dokuwiki

Written with help from OpenAI ChatGPT

# Requires
https://www.dokuwiki.org/plugin:publish 
https://www.dokuwiki.org/plugin:bureaucracy 
https://www.dokuwiki.org/plugin:struct 

# 1. Install Essential Plugins
Inside DokuWiki, go to:
Admin Panel → Extension Manager → Search and Install Plugins

  a. Publish Plugin (For Approval Workflow)
    Allows policies to move through draft, review, and published stages.
    Install:
      https://www.dokuwiki.org/plugin:publish
    Set min_approvals = 3 in Configuration Settings.
  b. Bureaucracy Plugin (For Approval Forms)
  Adds forms for policy approval requests.
  Install:
    https://www.dokuwiki.org/plugin:bureaucracy
  Create an approval form inside a page:
  ```
    ---- bureaucracy ----
    template    approval
    field       text "Policy Name"  
    field       text "Policy Owner"  
    field       email "Approver Email"
    action      mail compliance@example.com "Approval Required for @Policy Name"
    ----
  ```
  c. Struct Plugin (For Review Dates Without Versioning)
  Allows adding “Last Reviewed” fields.
    https://www.dokuwiki.org/plugin:struct
  Add a "review date" field to policies.

# 2. Multi-Step Approval Workflow
Scenario:
A policy requires three different people from an approval list to approve it before being published.

Solution:
Use the Bureaucracy Plugin to create an approval form.
Use a custom script to track approvals and auto-publish after three approvals.
Implementation:
Create an Approval Tracking File
Store approvals in /data/meta/approvals.json
Each policy is a key, tracking who approved it.
Custom PHP Script for Approvals
Script in lib/exe/approve.php
Create a Bureaucracy Form to Call the Script
Inside a page, add:

```
---- bureaucracy ----
template  approval
field     text "Policy ID"
field     hidden @USER
action    url https://yourdomain.com/lib/exe/approve.php?policy=@Policy_ID&user=@USER
----
```
When a user submits, it logs their approval.
After three approvals, the script moves the file from drafts to published.

# 3. Automatic Expiry & Review Reminders
Scenario:
Policies must be reviewed annually.
Send reminder emails to compliance managers.

Solution:
Use a cron job to check policies.
Send emails if a policy is older than 1 year.

Implementation:
Create a Review Date Tracker in Struct Plugin.
Add a last_reviewed field in Struct Plugin.
Custom Script to Check Policy Dates: lib/exe/check_reviews.php

Automate via Cron Job
```
crontab -e
```
Add:
```
0 4 * * 1 php /var/www/dokuwiki/lib/exe/check_reviews.php
```
Runs every Monday at 4 AM.
Sends an email if a policy needs review.

# 4. Require Additional Approval for High-Risk Policies
Scenario:
Some policies (Security, Compliance) need CIO or Legal Approval.
If “high_risk” tag is present, CIO must approve.

Solution:
Modify approve.php to check for high-risk tags.
Now, high-risk policies won’t auto-publish without CIO approval.

# File layout
```
/PolicyManager/
│── /approvals/                         # Backend scripts for policy approvals
│   │── approve.php
│   │── approve_policy.php
│   │── check_reviews.php
│   │── view_audit_log.php
│
│── /approvals_ui/                      # Frontend UI for managing approvals
│   │── index.html
│   │── /api/                            # API endpoints for UI functionality
│   │   │── approve_policy.php
│   │   │── get_approvals.php
│   │   │── reminder.php
│   │── /emails/                         # Email templates for notifications
│   │   │── approved_email.html
│   │   │── rejection_email.html
│   │   │── reminder_email.html
│
│── /config/                             # Configuration settings
│   │── local.php                        # DokuWiki configuration file
│
│── /dokuwiki_data/                      # Persistent DokuWiki data storage
│   │── /meta/                           # Stores approval and policy logs
│   │   │── approval_log.json
│   │   │── policies.json
│
│── docker-compose.yml                    # Docker Compose setup
│── Dockerfile                             # Custom Docker build file
```

