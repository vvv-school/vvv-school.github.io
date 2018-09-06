# How to complete assignments

We make use of [**GitHub Education**](https://education.github.com) to manage the assignments for the students.
Two methods are given to accomplish the assignment:

1. [**Smoke Testing the Code**](https://en.wikipedia.org/wiki/Smoke_testing_(software)). Preferred method during the courses.
2. [**Collaborative Code Review with Pull Requests**](https://help.github.com/articles/about-pull-requests).

## Instructions for **Students**

To start, click on the **invitation link** 🔘 the teachers gave you and **accept the assignment**. A **new repository** will be spawned from the repository containing the _starter code_. You'll receive an email when the repository is ready.

If you're dealing with a **tutorial** (i.e. the repository name starts with the prefix _tutorial_), then the starter code is already in its final version and you can use it to train yourself.

Instead, if you're dealing with an **assignment** (i.e. the repository name starts with the prefix _assignment_), then you are required to turn in your solution within the new repository.

#### Smoke Testing

This is the method we adopt for students during the courses.

>1. Make sure that the [**Robot Testing Framework**](https://robotology.github.io/robot-testing/index.html) is installed on your system. If you're using our VM, it is already installed :computer: :package:
>1. [**Clone**](https://help.github.com/articles/cloning-a-repository) the repository to your computer.
>1. [only **assignments**] Fill in the **gaps** and [**commit**](https://git-scm.com/docs/git-commit) changes to complete your solution ☕️☕️
>1. If present, go in the :smoking: **smoke-test** subdirectory and [run **`test.sh`**](../instructions/how-to-run-smoke-tests.md) to verify that the code complies with the requirements. 
>1. [only **assignments**] [**Push**](https://help.github.com/articles/pushing-to-a-remote)/sync the changes up to GitHub and watch feedback appearing as :white_check_mark: :x: [**statuses** attached to your commits](https://github.com/blog/1227-commit-status-api) :warning: Note that the statuses are handled by a remote server that needs to be online then.
>1. Check out the **course gradebook** by clicking on the commit status and boast of the result with your friends :triumph: :clap:

#### Collaborative Code Review

We adhere to the methodology well explained in this [post](https://blog.github.com/2018-05-29-pull-requests-in-the-classroom).

>1. [Create a **new branch**](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/) off of `master`; you may call it as your `username`.
>1. [**Clone**](https://help.github.com/articles/cloning-a-repository) the repository to your computer.
>1. Fill in the **gaps** and [**commit**](https://git-scm.com/docs/git-commit) changes to complete your solution ☕️☕️
>1. If there is a [**smoke test**](#smoke-testing), why don't you give it a try? :wink:
>1. [**Push**](https://help.github.com/articles/pushing-to-a-remote)/sync the changes up to GitHub.
>1. [Create a **pull request**](https://help.github.com/articles/creating-a-pull-request) (**PR**) with `master` as _base branch_ and `username` as _compare branch_.
>1. [**Request** a teacher to review your PR](https://help.github.com/articles/requesting-a-pull-request-review) :wave: to turn in the assignment.
>1. Address the points the teacher highlighted during the review 📝 by **pushing your fixes** and **replying to the comments** directly within the PR 🎓
>1. 💣 **Don't merge** and **don't close** the PR yourself 🔫 :smiley:

## Instructions for **Teachers**

#### Smoke Testing

>You don't have to do anything since we rely on **automatic grading** :relaxed:

#### Collaborative Code Review

>1. Once the student has created the PR, you can then do [**code review**](https://help.github.com/articles/about-pull-request-reviews) with line-by-line feedback. In case the student **did not create a new branch**, go blame the lounger 🔨😏. If your mood is good instead 😒, then you can still launch a PR based review by doing: (a) within the new repository **navigate to the last commit of the starter code**, which precedes the first commit the student pushed to `master`; (b) [create a **new branch** off of that commit](https://github.com/blog/1377-create-and-delete-branches) and call the branch `review-teacherusername`; (c) start a **pull request** with `review-teacherusername` as _base branch_ and `master` as _compare branch_; (d) you can now proceed with **code review**.
>1. Also, provide within the PR a **brief summary** including, but not limited to, the following general remarks: (a) Is the code sufficiently **commented**? (b) What about **indentation** and **code style**? (c) Is the code **cross-compilable**? (d) Are there **warnings** still left? (e) Is the **code architecture** well designed in terms of **components**, **operations**, **synchronism**? (f) To which **extent** are the requirements accomplished?
>1. Once the student has positively addressed all the points 👍🎉, **merge the PR** only if `master` is the _base branch_, otherwise just **close the PR** 👈
>1. Finally, to avoid overcrowding the organization, arrange to [transfer the **ownership**](https://help.github.com/articles/transferring-a-repository-owned-by-your-organization) of the repository to the student GitHub account 💰. You can use your account as intermediate step since a direct transfer from the organization to other users is not allowed. Alternatively, you can ask the student to [**import** the repository](https://help.github.com/articles/importing-a-repository-with-github-importer) into their own account; once done, you can delete the student's repository on this organization. Importantly, either transferring the ownership or importing the repository will also enable students to **retain forever the outcome of their hard work** :muscle: making sure that deleting the assignment from the _GitHub Education_ dashboard won't cause any unwanted side effect. While transferring/importing, make sure that if the original repository is private, then it will **remain private** in order to keep code undisclosed as intended :wink:
>
>Sometimes, it might be beneficial to commit code to student's repository. To this end, follow these steps:
>
>1. **Create the branch** `review-teacherusername` off of the student's solution.
>1. **Commit** new code to `review-teacherusername`.
>1. **Open the PR**.
