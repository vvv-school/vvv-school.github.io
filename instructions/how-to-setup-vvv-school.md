# How to set up a VVV{YY} School

**YY** is the school year (e.g. **17**, **18**...)

## VVV{YY} School Repository

The repository will be named **vvv-school/vvv{yy}** (e.g. [vvv-school/vvv17](https://github.com/vvv-school/vvv17)).

Everything is mostly done, since we can  [**duplicate** the repository](https://help.github.com/articles/duplicating-a-repository/#mirroring-a-repository) **vvv{yy-1}** into **vvv{yy}**.

Then, do the following steps:
- If you didn't do it while creating the new repository, edit the **description** and the **website** fields of the repository page with, respectively, **Resources for VVV{YY} School** and **https://vvv-school.github.io/vvv{yy}**.
- Within [vvv-school](https://github/vvv-school), [create two **teams**](https://help.github.com/articles/creating-a-team): **vvv{yy}-teachers** and **vvv{yy}-students**. Start off filling in the teachers team for the time being, while we will be waiting for all students to sign up on GitHub. Remember that teams visibility is restricted to the organization's members, hence don't spread out links to them, since non-members won't be able to access teams info.
- Replace all the links in **README.md**, **teachers.md** and **students.md** files.
- Create a [**welcome issue**](https://github.com/vvv-school/vvv17/issues/1) in **Q&A**. Don't forget to replace links therein.
- Create just one page in the **Wiki** containing the [**instructions to follow before arriving at VVV**](https://github.com/vvv-school/vvv17/wiki/Before-arriving-at-VVV) and link it from within the Wiki home page. We have a [**template**](../instructions/before-arriving-at-vvv.md) for it, but you would need to tailor it slightly in order to adjust links to resources (e.g. new Q&A, new mailing list...). If there are instructions that are likely to be reused for upcoming schools, don't forget to **update the template** accordingly.
- [Configure the **GitHub Pages**](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/#enabling-github-pages-to-publish-your-site-from-master-or-gh-pages) to publish from the **`master`** branch. The file **`_config.yml`** used by GitHub Pages to set up the style should be already contained inside the repository (thanks to duplication).
- Fill in the file **gradebook.md** with proper links to the GitHub page of the [gradebook repositories](#vvvyy-school-gradebook-repository).

## Set up VVV{YY} School Gradebook Organizations



### VVV{YY} School Gradebook Repository

A gradebook repository contains a **main repository along with 
