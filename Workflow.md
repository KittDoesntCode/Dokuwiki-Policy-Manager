# Policy Approval Workflow in DokuWiki
This workflow ensures that draft policies remain hidden, go through a three-person approval process, and are published only after full approval.

## Step 1: Create a Draft Policy
Log in as an authorized user (policy creator) in DokuWiki.
Navigate to the appropriate namespace (e.g., wiki:policies).
Click Create Page and enter the draft content.
Save the policy as a draft by including metadata at the top of the page:
```
~~META:
approved: false
approvers: []
last_reviewed: 
~~
```
Only logged-in users with edit permissions (e.g., @policy_editor group) can see draft policies.
✅ Result: Draft policy is created but hidden from public/guest users.

## Step 2: Submit Policy for Approval
Navigate to the Approvals UI (```/approvals_ui/index.html```).
Find the draft policy in the list.
Click “Submit for Approval” (calls ```approve_policy.php```).
This triggers an email notification to the first approver, using ```approvals_ui/emails/reminder_email.html```.

✅ Result: The first approver is notified to review the policy.

## Step 3: Multi-Step Approval Process (3 Approvers)
Approvers follow these steps:

Log in and visit ```/approvals_ui/index.html```.

Click "Review Policy", which loads policy content from ```get_approvals.php```.

Click "Approve" or "Reject":

If approved, the approver’s name is added to the metadata.
If rejected, a comment is required, and the submitter is notified using rejection_email.html.
When the third approver approves, the policy is officially published:

approve_policy.php updates metadata:
```
~~META:
approved: true
approvers: John Doe, Jane Smith, CIO
last_reviewed: 2024-02-06
~~
```
A notification is sent using ```approved_email.html```.

✅ Result: The policy is now marked as approved and visible to public users.

## Step 4: Publishing the Approved Policy
Once approved, the page is automatically visible due to the template changes in ```main.php```:
```
if (!$isApproved && !auth_isadmin() && !auth_ismanager()) {
    echo "<p style='color:red;'>This policy is not yet approved.</p>";
    exit; // Hide content if not approved
}
```
Approved policies are listed in policy_list (policy_list.txt in the wiki):
```
{{page>policy1}}
{{page>policy2}}
```
The last reviewed date is updated without creating a new version, using check_reviews.php.

✅ Result: The policy is now public and visible to all users.

## Step 5: Annual Review & Expiry Management
An automatic script (```check_reviews.php```) runs periodically to:
Identify policies last reviewed over a year ago.
Send reminder emails to the policy owners.
Managers can quickly update the review date without changing the policy text:
Navigate to Approvals UI (```/approvals_ui/index.html```).
Click “Mark as Reviewed” (updates last_reviewed).

✅ Result: Policies stay current and compliant without unnecessary updates.

## Summary of the Workflow

|Step | Action | User Role | Files/Tools Used |
|-----|--------|-----------|------------------|
|1 | Create Draft Policy | Policy Creator | DokuWiki Editor |
|2 | Submit for Approval | Policy Creator | ```approve_policy.php``` |
|3 | Approve (3 Steps) | 3 Approvers | ```get_approvals.php```, ```approve_policy.php``` |
|4 | Publish | Automatic | ```main.php```, ```policy_list.txt``` |
|5 | Review Annually | Policy Managers | ```check_reviews.php``` |

This workflow ensures only approved policies are public, drafts remain restricted, and reviews happen on time.
