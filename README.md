# SourceCred Template Instance

This repository contains a template for running a SourceCred instance.

New users of SourceCred are encouraged to use this template repo to start their own
instance.

This repo comes with a GitHub action configured that will run SourceCred automatically
every 24 hours, as well as any time you change the configuration.

# About SourceCred Instances

SourceCred is organized around "instances". Every instance must have a
`sourcecred.json` file at root, which specifies which plugins are active in the
instance. Config and permanent data (e.g. the Ledger) are stored in the main branch.
All output or site data gets stored in the `gh-pages` branch by the Github Action.

Configuration files:

- `config` has JSON files that will be hand-edited to configure your instance (more on this below).

Permanent Data:

- `data/ledger.json` keeps a history of all grain distributions and transfers as well as identities added / merged. This should not be hand-edited.

Generated Data:

- `cache/` stores intermediate produced by the plugins. This directory should
  not be checked into Git at all.
- `output/` stores output data generated by SourceCred, including the Cred
  Graph and Cred Scores. This directory should be checked into Git; when
  needed, it may be removed and re-generated by SourceCred.
- `site/` which stores the compiled SourceCred frontend, which can display data
  stored in the instance.

# Setup and Usage

Using this instance as a starting point, you can update the config to include
the plugins you want, pointing at the data you care about. We recommend setting up
your instance locally first and make sure its working before pushing your changes
to main and using the Github Action.

**Setting up a SourceCred Instance requires basic knowledge of:**
- using a terminal
- using git
- hand-editing JSON files

## Step 1: Do Initial Setup

1. Hit the big green "Use this template" button on github. (do not fork)

1. Use a **git** client to clone your new repo locally.

1. Get [Yarn], navigate to the cloned repo directory in a terminal, and then run `yarn` to install SourceCred and dependencies.

1. Enable the plugins you want to use by updating the `sourcecred.json` file. e.g.
   to enable all the plugins:

```json
{
  "bundledPlugins": [
    "sourcecred/discourse",
    "sourcecred/discord",
    "sourcecred/github"
  ]
}
```
- To deactivate a plugin, just remove it from the `bundledPlugins` array in the `sourcecred.json` file.
You can also remove its `config/plugins/OWNER/NAME` directory for good measure.

5. If you are using the GitHub or Discord plugin, copy the `.env.example` file to a `.env` file:

```shell script
cp .env.example .env
```

## Step 2: Configure Plugins

### GitHub

The GitHub plugin loads GitHub repositories.

You can specify the repositories to load in
`config/plugins/sourcecred/github/config.json`.

In order for SourceCred to access your GitHub repos,
you must have a GitHub API key in your `.env` file as
`SOURCECRED_GITHUB_TOKEN=<token>` (copy the `.env.example` file for reference). The key should be read-only without any special
scopes or permissions (unless you are loading a private GitHub repository, in which case
the key needs access to your private repositories).

You can generate a GitHub API key [here](https://github.com/settings/tokens).

### Discourse

The Discourse plugin loads Discourse forums; currently, only one forum can be loaded in any single instance. This does not require any special API
keys or permissions. You just need to set the server url in `config/plugins/sourcecred/discourse/config.json`. The discourse forum must be publicly accessible via the URL that is set, however. The forum must be accessible without a login.

### Discord

The Discord plugin loads Discord servers, and mints Cred on Discord reactions. In order for SourceCred to
access your Discord server, you need to generate a "bot token" and paste it in the `.env` file as
`SOURCECRED_DISCORD_TOKEN=<token>` (copy the `.env.example` file for reference).

The full instructions for setting up the Discord plugin can be found in the [Discord plugin page](https://sourcecred.io/docs/beta/plugins/discord/#configuration)
in the SourceCred documentation.

## Step 3: Configure PageRank Weights
Our current core algorithm is a variation of an algorithm called PageRank. This is a graph-based algorithm that requires weights to be set for the nodes and edges. We provide default weights, and if you want, you can skip this section for now. When you're ready to decide for yourself how Cred should flow through the graph, follow these instructions:
1. Run `yarn sourcecred serve`, open `localhost:6006` in a browser, and navigate to the Weight Configuration page.
2. Set the node and edge weights for each plugin. See [this guide](https://sourcecred.io/docs/beta/cred#choosing-weights) and the [plugin docs](https://sourcecred.io/docs/beta/plugins/github/) for help.
3. Click "Download weights", move the downloaded file from your downloads folder to the `config/` folder in your instance, and then make sure the name is exactly `weights.json`

## Step 4: Configure Dependency Cred

In `config/dependencies.json` you'll notice there is a default configuration for recognizing SourceCred as a dependency that powers your community. This will create bonus Cred and give it to an identity named `sourcecred`, which will be activated to receive rewards. By default it is set to 0.05 (5% of minted Cred).

If you choose to keep or increase our dependency cred, rewards distributed to our community support the longevity and development of the project. If you are interested in possibly getting extra tech support or feature prioritization for higher depencency cred, reach out on [Discord](https://sourcecred.io/discord) in our _#any-questions_ channel! If you want to lower or remove the dependency cred, we're dedicated to open source and you totally can.

## Step 5: Test with the CLI

Use the following commands to run your instance locally:

**Load Data**

- `yarn load` loads the data from each plugin into the cache. Run this anytime you want to re-load the data from
  your plugins.

**Run SourceCred**

- `yarn start` creates the cred graph, computes cred scores and runs the front end interface which you can access at `localhost:6006`
  in your browser.

NOTE: this command will not load any new data from Discord / GitHub / Discourse, etc. If you want to re-load
all the latest user activity, run `yarn load` again.


**Troubleshooting**

- `yarn clean` will clear any cached data that was loaded by the plugins. You can run this if any plugins fail to load. Run `yarn load` and `yarn start` after this to refresh the data.

- `yarn clean-all` gives you and even cleaner state. Run it if the `yarn start` command fails due to a change in the config or breaking changes in a new version of SourceCred, and then run `yarn load` and `yarn start` to refresh.

If you continue to run into errors, check our [Tech Support FAQ](https://sourcecred.io/docs/setup/FAQ). If you don't see your error there, or you need more help, hop into our [Discord](https://sourcecred.io/discord) and ask in the #tech-support channel.

## Step 6: Set Up GitHub Actions
1. Once you get `yarn start` working, push your local changes to GitHub.
1. _(Skip this if you are not using the Discord or GitHub plugins.)_ In GitHub, go to your repository's Settings tab and click Secrets in the left sidebar. Add the API tokens from your local .env file by clicking _New repository secret_ and adding SOURCECRED_<PLUGIN>_TOKEN as the name and the token as the value.
1. Go to the repository's Actions tab. If the most recent Generate Cred Instance workflow has failed, click into it and click "Re-run all jobs". Wait or come back to verify that Generate Cred Instance succeeds.

## Step 7: Publish with GitHub Pages
The Generate Cred Instance workflow has deployed a static site to a branch called `gh-pages`.
1. Go to Settings > Pages
1. Select the gh-pages branch if it is not already selected.
1. Click "Select theme" and then click the green "Select Theme" to choose a random theme. This is required but it does not matter what theme is chosen.
1. Verify that the URL it gives you works.


## Step 8: Distribute Rewards
By default, rewards are called Grain by SourceCred. If you would like to re-skin the rewards to represent your community's token, edit `config/currencyDetails.json`

The command `yarn grain` distributes Grain according to the current Cred scores, and the config in `config/grain.json`. This repo contains a GitHub Action for automatically distributing Grain. It will run every Sunday and create a Pull Request
with the ledger updated with the new grain balances based on the users Cred scores. If you want to skip the Pull Request step and commit directly to the main branch, read and edit `.github/workflows/distribute-grain.yml`. The amount of grain distributed
every week can be defined in the `config/grain.json` file.

There are three different policies that can be used to control
how the grain gets distributed: "IMMEDIATE", "BALANCED", and "RECENT". For info on what each policy does, how to choose the right policy for your community, and how Grain operates in general, see [How Grain Works](https://sourcecred.io/docs/beta/grain).

**Example Grain Configuration**

Below is an example `grain.json` file for a configuration that uses a combination of all three policies. Here we tell SourceCred to distribute 1,000 grain every week, with 25% (250 grain) distributed according to `IMMEDIATE`, 25% (250 grain) distributed according to `BALANCED`, and 50% (500 grain) distributed according to `RECENT`. `MaxSimultaneousDistributions` can be used to back-fill multiple weeks of missing distributions, but can usually just be kept at 1.

```json
{
 "maxSimultaneousDistributions": 1
 "allocationPolicies": [
    {
      "budget": "250",
      "numIntervalsLookback": 1,
      "policyType": "IMMEDIATE"
    },
    {
      "budget": "450",
      "discount": 0.5,
      "policyType": "RECENT"
    },
    {
      "budget": "250",
      "numIntervalsLookback": 0,
      "policyType": "BALANCED"
    }
  ]
}
```

## That's it!
You've set up a SourceCred instance! We'd love to know you're out there. _**Introduce yourself and link your repository**_ on our [Discord](https://sourcecred.io/discord) or @ us on [Twitter](https://twitter.com/sourcecred).

# Beyond the basics

If you want to go deeper, you can access lower-level commands in the SourceCred CLI in the form of: `yarn sourcecred <command>`.
For a list of what's available, and what each command does, run `yarn sourcecred help`. Then run `yarn sourcecred help <command name>` to see what feature flags are available for each command.


[yarn]: https://classic.yarnpkg.com/
