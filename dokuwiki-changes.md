# Changes Needed in DokuWiki for Policy Approval System
To fully integrate the policy approval system into DokuWiki, you will need to make changes in templates, pages, and configuration files. Below are the required modifications categorized by area:

1. Template Changes (UI Customization)
These changes ensure that approved policies display approval details and draft policies remain hidden from public users.

A. Modify ```tpl/default/main.php``` (or your active template’s main.php)
Add approval metadata to each policy page.
Restrict draft policies to only authorized users.

Steps:
Locate your active template directory in ```dokuwiki/lib/tpl/default/``` (or your chosen template).
Edit ```main.php``` and insert the following code inside the <body> tag:
```
<?php
global $ID;
$isApproved = p_get_metadata($ID, 'approved');
$approvers = p_get_metadata($ID, 'approvers');
$lastReviewed = p_get_metadata($ID, 'last_reviewed');

if (!$isApproved && !auth_isadmin() && !auth_ismanager()) {
    echo "<p style='color:red;'>This policy is not yet approved.</p>";
    exit; // Hide the content if not approved
}
?>
```
Explanation:
If a policy is not approved, non-admin users won’t be able to see it.
Shows approvers and last review date on approved policies.

2. Configuration Changes (```local.php```)
DokuWiki’s configuration should be modified to:

Ensure metadata is stored for approvals.
Restrict draft visibility to only certain groups.
A. Modify conf/local.php
Ensure DokuWiki uses metadata by adding the following:
```
$conf['useacl'] = 1; // Enable access control
$conf['superuser'] = '@admin'; // Admin group
$conf['manager'] = '@manager'; // Manager group
```

3. Page Changes (Custom Approval Display)
You need to display approval details on each policy page.

A. Modify ```conf/lang/en/lang.php``` to Show Approval Status
Edit ```conf/lang/en/lang.php``` and add:
```
$lang['approved_by'] = "Approved by:";
$lang['last_reviewed'] = "Last Reviewed:";
```

B. Add Metadata to Policy Pages
Open an approved policy page in the editor.
Add metadata at the top of the page:
```
~~META:
approved: true
approvers: John Doe, Jane Smith, CIO
last_reviewed: 2024-02-01
~~
```

4. Add an "Approve Policy" Button (Optional)
To allow designated users to approve a policy directly in the wiki:

A. Modify ```lib/plugins/approvepolicy/action.php```
```
<?php
if (!defined('DOKU_INC')) die();

global $ID;
if (auth_isadmin() || auth_ismanager()) {
    echo '<form action="/approvals/approve.php" method="POST">
        <input type="hidden" name="policy_id" value="'.$ID.'">
        <button type="submit">Approve Policy</button>
    </form>';
}
?>
```

Explanation:
Adds an "Approve Policy" button for admins.
Submits approval to /approvals/approve.php.
5. Policy List Page with Approval Status
To create a publicly visible list of policies with approval status:

Create a new wiki page called policy_list.
Add the following syntax:
```
===== Policy List =====
{{page>policy1}}
{{page>policy2}}
{{page>policy3}}
```
This will dynamically list approved policies.

# Summary of Required Changes
Area	File / Setting	Purpose

Templates	```lib/tpl/default/main.php```	Hide unapproved policies, show metadata.

Configuration	```conf/local.php```	Enable ACL, restrict draft visibility.

Language	```conf/lang/en/lang.php```	Add approval-related language strings.

Metadata	Pages (~~META~~)	Track approval status and review dates.

Approval Button	```lib/plugins/approvepolicy/action.php```	Add an approval button.

Policy List Page	```/policy_list```	Show approved policies.

These changes will ensure that only approved policies are publicly visible while allowing managers/admins to approve and track policy reviews.
