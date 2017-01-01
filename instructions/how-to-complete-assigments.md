# How to complete assignments

We make use of [**GitHub Education**](https://education.github.com) to manage the assignments for the students.

### Instructions for **Students**

1. To start, click on the **invitation link** 🔘 the teachers gave you. A **new repository** will be spawned from the repository containing the _starter code_. You are required to provide your solution in this new repository.
2. [Create a **new branch**](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/) from `master`; you may call it as your `username`.
3. [**Clone**](http://gitref.org/creating/#clone) the repository to your computer.
4. Fill in the **gaps** and [**commit**](http://gitref.org/basic/#commit) changes to complete your solution ☕️☕️
5. [**Push**](http://gitref.org/remotes/#push)/sync the changes up to GitHub.
6. [Create a **pull request**](https://help.github.com/articles/creating-a-pull-request) (**PR**) with `master` as _base branch_ and `username` as _compare branch_.
7. [**Request** a teacher to review your PR](https://help.github.com/articles/requesting-a-pull-request-review/) :wave: to turn in the assignment.
8. Address the points the teacher highlighted during the review 📝 by **pushing your fixes** and **replying to the comments** directly within the PR 🎓
9. 💣 **Don't merge** and **don't close** the PR yourself 🔫

### Instructions for **Teachers**

1. Once the student has created the PR, you can then do [**code review**](https://help.github.com/articles/about-pull-request-reviews) with line-by-line feedback. In case the student **did not create a new branch**, go blame the lounger 🔨😏. If your mood is good instead 😒, then you can still launch a PR based review by doing:
    1. Within the new repository **navigate to the last commit of the starter code**, which precedes the first commit the student pushed to `master`.
    2. [Create a **new branch** off of that commit](https://github.com/blog/1377-create-and-delete-branches); call the branch `review-teacherusername`.
    3. Start a **pull request** with `review-teacherusername` as _base branch_ and `master` as _compare branch_.
    4. You can now proceed with **code review**.
2. Also, provide within the PR a **brief summary** including, but not limited to, the following general remarks:
    - Is the code sufficiently **commented**? What about **indentation** and **code style**?
    - Is the code **cross-compilable**? Are there **warnings** still left?
    - Is the **code architecture** well designed in terms of **components**, **operations**, **synchronism**?
    - To which **extent** are the requirements accomplished?
3. Once the student has positively addressed all the points 👍🎉, **merge the PR** only if `master` is the _base branch_, otherwise just **close the PR** 👈
4. To avoid overcrowding the organization, arrange to [transfer the **ownership**](https://help.github.com/articles/transferring-a-repository-owned-by-your-organization) of the repository to the student GitHub account 💰. Transferring the ownership could be _optional_ if you decide to jump straight to step 5.
5. Finally, applying step 4 does not guarantee that the student can retain the repository forever, since deleting the assignment from the _GitHub Education_ dashboard will cause that all the participant repositories will be deleted too 😲. To prevent this, ask the student to [**duplicate** the repository](https://help.github.com/articles/duplicating-a-repository/#mirroring-a-repository).

Sometimes, it might be beneficial to commit code to student's repository. To this end, follow these steps:

1. **Create the branch** `review-teacherusername` off of the student's solution.
2. **Commit** new code to `review-teacherusername`.
3. **Open the PR**.
