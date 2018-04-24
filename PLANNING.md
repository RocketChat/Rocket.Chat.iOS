# Mobile Team Releases Planning

This document describes the suggested method by which our mobile teams should plan for releases.

**What’s a release?**

The release is every version of the app that’s sent to the store as a production release. The release is always a major/minor update, like from (1.0.0 to 1.1.0 or to 2.0.0). Patch releases (from 1.0.0 to 1.0.1) won’t follow these steps and are considered hotfixes releases. Our versioning is following the [Semantic Versioning 2.0.0](https://semver.org) guide.

**What are the important days of a release?**

The first release candidate (TestFlight and Beta) needs be done by 27th of each month. The release will always happen on day 5th of each month, unless there’s some critical crash/bug happening.

**What happens if something could not be done in time for the release candidate?**

In general, if it’s a new feature, it’ll be postponed for the next release only. Under extreme circumstances, when it will result in significant business impact a extraordinary release could happen. 

**When do we plan the release features/improvements/bugs?**

Every month can be a different day between 27th and 5th to plan the next release. The leader of the team will schedule the session and all the team will be able to participate in the planning. At this moment, most of the issues will be assigned to each member of the team.

Example (in April, 2018):

| Day        | Description             |
|------------|-------------------------|
| 27th Mar ~ 5th Apr | Planning new cycle      |
| 5th Apr       | Start new release cycle |
| 27th Apr       | Release candidate       |
| 5th May       | Production release       |


**How do we organize a release?**

Every release is a Project in GitHub. There are 6 boards on each project:

- **Desirable (temporary):** what we want to have on the release. This is very useful while planning. This is where everybody can add features/improvements that wanna see on the release;
- **Blocked:** when something is blocked (waiting asset, waiting API, etc) the issue will be on this board;
- **To-do:** after planning, all to-do issues come here;
- **In progress:** when something is in progress, the issue/PR will be on this board;
- **Review/QA:** when something is done and waiting for review or waiting to be tested, the issue/PR will be on this board;
- **Done:** when the issue is closed (merged), the issue/PR will be on this board;


**What happens when the release candidate is shipped?**

All changes in develop needs to be merged into the branch beta at this point. A new tag needs to be created following the pattern: “2.1.0-beta1”.


**What happens if there’s no bug/crash on the release candidate?**

That’s great, congrats! This time can be used in a creative way: write more tests, code maintenance that sometimes is required, resolving issues to the next release, planning, ideas and experiments.


**What happens when the release is done?**

Project and milestones are closed, all the changes are merged to the branch master and the tag is created, following the release’s pattern of the repository. 


## Hotfix Releases

**When a hotfix release happen?**

Hotfix release will happen when a critical bug or crash is found in the production version of the app.


**How to handle hotfix releases?**

Simply open an issue on GitHub describing the issue, the issue is usually closed from a pull-request getting merged and a new milestone is created with the minor update, including all PRs required to the hotfix be completed. Once the milestone is completed, it can be closed and the release tag can be created.
