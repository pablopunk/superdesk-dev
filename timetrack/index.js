#!/usr/bin/env node
const got = require('got')
const cheerio = require('cheerio')

/* eslint-disable no-extend-native */
Array.prototype.flat = function() {
  return [].concat(...this)
}
Array.prototype.equals = function(anotherArray) {
  return JSON.stringify(this) === JSON.stringify(anotherArray)
}
// This method is only for arrays of arrays [[], []...]
Array.prototype.unique = function() {
  return this.reduce((acc, curr) => {
    const exists = acc.find(element => element.equals(curr))
    if (!exists) {
      acc.push(curr)
    }
    return acc
  }, [])
}

const PROJECTS = ['client-core', 'belga', 'planning', 'fi', 'ntb']

// { since: 2019-07-31, until: 2019-08-31 }
const getThisMonthRange = (lastMonth = false) => {
  const minusOneMonth = lastMonth ? 1 : 0
  const now = new Date()
  const year =
    lastMonth && now.getMonth() === 0
      ? now.getFullYear() - 1
      : now.getFullYear()
  const month =
    year !== now.getFullYear() ? 11 : now.getMonth() - minusOneMonth
  const lastDayOfLastMonth = new Date(
    month === 0 ? year - 1 : year,
    month === 0 ? 11 : month,
    0
  ).getDate()
  const lastDayOfThisMonth = new Date(year, month + 1, 0).getDate()

  return {
    since: `${month === 0 ? year - 1 : year}-${
      month === 0 ? 12 : month
    }-${lastDayOfLastMonth}`,
    until: `${year}-${month + 1}-${lastDayOfThisMonth}`
  }
}

async function getCommitsForProject(project, { since, until }) {
  const range = `since=${since}&until=${until}`
  const url = `https://github.com/superdesk/superdesk-${project}/commits?author=pablopunk&${range}`
  const res = await got(url)
  const $ = cheerio.load(res.body)
  const commits = []
  const promises = []
  $('.commit').each((i, commit) => {
    const title = $(commit)
      .find('.commit-title>a:first-child')
      .attr('aria-label')
    const prLink = $(commit)
      .find('.commit-title>.issue-link')
      .attr('href')
    if (prLink) {
      promises.push(
        got(prLink).then(prRes => {
          const $pr = cheerio.load(prRes.body)
          const description = $pr('.comment-body')
            .eq(0)
            .text()
          const date = new Date(
            $(commit)
              .find('relative-time')
              .attr('datetime')
          )
          commits.push({ title, date, description })
        })
      )
    }
    return {}
  })

  await Promise.all(promises)

  return commits
}

function extractProjectsFromTasks(projects) {
  const projectsFromTasks = {}

  projects.map(({ name, commits }) => {
    commits.map(commit => {
      const matches = commit.description.match(/SD.*[-]\d+/)

      if (matches) {
        const [task] = matches
        const projectFromTask = task.replace(/-.*/, '')

        if (projectsFromTasks.hasOwnProperty(projectFromTask)) {
          projectsFromTasks[projectFromTask].commits.push(commit)

          const existingProject = projectsFromTasks[projectFromTask]

          if (existingProject.latest.getTime() > commit.date.getTime()) {
            projectsFromTasks[projectFromTask].latest = commit.date
          }
        } else {
          projectsFromTasks[projectFromTask] = { commits: [commit] }
          projectsFromTasks[projectFromTask].latest = commit.date
        }
      }
    })
  })

  return projectsFromTasks
}

function flatCommits(projects) {
  const unflattenCommits = Object.entries(
    projects
  ).map(([project, { commits }]) =>
    commits.map(commit => ({ ...commit, project }))
  )
  return unflattenCommits.flat()
}

function getTimelineFromProjects(projects) {
  const allComits = flatCommits(projects)
  const commitsInOrder = allComits.sort(
    (c1, c2) => c1.date.getTime() - c2.date.getTime()
  )
  const timeline = commitsInOrder
    .map(({ date, project }) => [date.toLocaleDateString(), project])
    .unique()
  const timelineObj = {}
  for (const [date, project] of timeline) {
    timelineObj[date] = project
  }
  return timelineObj
}

async function main({ last = false } = {}) {
  const range = getThisMonthRange(last)
  console.log(`From ${range.since} until ${range.until}`)
  const getProjectPromises = PROJECTS.map(async project => {
    const commits = await getCommitsForProject(project, range)

    return { name: project, commits }
  })

  Promise.all(getProjectPromises).then(projects => {
    const projectsFromTasks = extractProjectsFromTasks(projects)
    const timeline = getTimelineFromProjects(projectsFromTasks)
    if (Object.keys(timeline).length === 0) {
      console.log('Empty')
    } else {
      console.table(timeline)
    }
  })
}

let args = process.argv.slice(2)
args = args.reduce((acc, curr) => {
  acc[curr] = true
  return acc
}, {})
main(args)
