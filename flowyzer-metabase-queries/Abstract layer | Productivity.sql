WITH pr_commit AS (
    SELECT *, REGEXP_REPLACE(prc."pullRequest", '\|\d+$', prc."commit") AS "tranformed_pr_id"
    FROM "vcs_PullRequestCommit" AS prc
)
SELECT
    pr.id AS "prId",
    pr.origin AS "prOrigin",
    pr.number AS "prUID",
    pr.author AS "prAuthor",
    pr."createdAt" AS "prCreatedAt",
    pr."updatedAt" AS "prUpdatedAt",
    pr."mergedAt" AS "prMergedAt",
    pr."stateDetail",
    pr."stateCategory",
    pr_comment.id AS "commentId",
    pr_comment.comment,
    pr_comment."createdAt" AS "commentCreatedAt",
    pr_comment.author,
    pr_commit.tranformed_pr_id AS "prCommitId",
    commit.sha,
    commit.message AS "commitMessage",
    commit."createdAt" AS "commitCreatedAt",
    commit.author AS "commitAuthor",
    (CASE WHEN "user".name IS NULL THEN commit.author ELSE "user".name END) AS "commitAuthorName",
    commit."linesAdded",
    commit."linesDeleted",
    commit."linesChanged",
    GREATEST(pr."updatedAt", pr."mergedAt", pr_comment."createdAt", commit."createdAt") AS "lastActivityTime",
    org.id AS "orgId",
    org.uid AS "orgUID",
    repo.id AS "repoId",
    repo.origin AS "repoOrigin",
    repo.name AS "repoName",
    repo."fullName" AS "repoFullName"
FROM "vcs_PullRequest" AS pr
LEFT JOIN "vcs_PullRequestComment" AS pr_comment
    ON pr_comment."pullRequest"=pr.id
JOIN "vcs_Repository" As repo
    ON repo.id=pr.repository
JOIN "vcs_Organization" AS org
    ON org.id=repo.organization
JOIN pr_commit
    ON pr_commit."pullRequest" = pr.id
LEFT JOIN "vcs_Commit" AS commit
    ON commit.id=pr_commit.tranformed_pr_id
LEFT JOIN (
    SELECT * FROM "vcs_User" WHERE "vcs_User".name IS NOT NULL
) AS "user"
    ON LOWER("user".id)=LOWER(commit.author)
ORDER BY pr.id