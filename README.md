## Gw____tt COVID-19 Dashboard

This repo scrapes data from [PDF reports](https://bit.ly/2HpqhaY) put together by the [Gw____tt School District](https://bit.ly/2HyCJoi), packages it with a shiny web app built by a collaborator, then deploys it to <https://shinyapps.io>.
We also automatically upload up-to-date consolidated datasets to [the project's Open Science Framework page](https://osf.io/q2f36/) --- if you like, hop over there to grab a copy of the raw data.

Check out live the Covid Dashboard app [here](https://bit.ly/3dYitII).

## Play-By-Play of the Build Process

We use [Travis CI](https://travis-ci.com/) to build.
Travis automatically launches jobs in response to fresh commits to certain branches on this repo.
You can peek at this repo's current build jobs [here](https://travis-ci.com/github/mmore500/g-fyi).

1. A pdf gets added to the [`input/` folder](https://github.com/mmore500/g-fyi/tree/raw-data/input) on the [`raw-data` branch](https://github.com/mmore500/g-fyi/tree/raw-data).
2. Travis launches a build  on the [`raw-data` branch](https://github.com/mmore500/g-fyi/tree/raw-data) to extract tables from all pdfs in `input/`, generating one csv file per dataset in the pdf.
(All content from datasets split over multiple pages end up in the same csv.)
3. A copy of the [`data-joiner` branch](https://github.com/mmore500/g-fyi/tree/data-joiner) is cloned down and the csv files are loaded into its `input/` folder.
4. The loaded-up [`data-joiner` branch](https://github.com/mmore500/g-fyi/tree/data-joiner)is force-pushed to the [`parsed-data` branch](https://github.com/mmore500/g-fyi/tree/parsed-data).
5. Travis launches a job on the [`parsed-data` branch](https://github.com/mmore500/g-fyi/tree/parsed-data) to join csv files corresponding to different report dates.
6. A copy of the [`app-builder` branch](https://github.com/mmore500/g-fyi/tree/data-joiner) is cloned down and the joined csv files are loaded up into its root directory.
7. The loaded-up [`parsed-data` branch](https://github.com/mmore500/g-fyi/tree/data-joiner) branch is force-pushed to the [`built-app`](https://github.com/mmore500/g-fyi/tree/parsed-data).
8. Travis launches a job on the [`parsed-data` branch](https://github.com/mmore500/g-fyi/tree/parsed-data) to build our shiny app and deploy it.

## Acknowledgement

The idea of scraping data out of pdfs for this project was inspired by [@jaredmoore](https://github.com/jaredmoore/)'s [covid_tracker](https://github.com/jaredmoore/covid_tracker) project.
