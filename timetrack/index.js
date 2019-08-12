#!/usr/bin/env node
const got = require('got')
const cheerio = require('cheerio')

const PROJECTS = [
  'client-core',
  'belga',
  'planning',
  'fi',
  'ntb'
]

// { since: 2019-07-31, until: 2019-08-31 }
const getThisMonthRange = () => {
  const now = new Date()
  const lastDayOfLastMonth = (new Date(now.getFullYear(), now.getMonth(), 0)).getDate()
  const lastDayOfThisMonth = (new Date(now.getFullYear(), now.getMonth() + 1, 0)).getDate()

  return {
    since: `${now.getFullYear()}-${now.getMonth()}-${lastDayOfLastMonth}`,
    until: `${now.getFullYear()}-${now.getMonth() + 1}-${lastDayOfThisMonth}`
  }
}

async function getCommitsForProject(project, { since, until }) {
  const range = `since=${since}&until=${until}`
  const url = `https://github.com/superdesk/superdesk-${project}/commits?author=pablopunk&${range}`
  const res = await got(url)
    .catch(() => console.log(url))
  const $ = cheerio.load(res.body)
  const commits = []
  $('.commit').each((i, commit) => {
    const title = $(commit).find('.commit-title>a:first-child').attr('aria-label')
    const date = new Date($(commit).find('relative-time').attr('datetime'))
    commits.push({ title, date })
  })

  return commits
}

async function main() {
  const range = getThisMonthRange()
  const projects = PROJECTS.map(async (project) => {
    const commits = await getCommitsForProject(project, range)

    return { name: project, commits }
  })

  Promise.all(projects)
    .then(projects => {
      projects.map(({ name, commits }) => {
        console.log('\n')
        console.log(name.toUpperCase())
        console.log('===')
        commits.length
          ? commits.map(({ title, date }) => {
            console.log(`\n${date.toLocaleDateString('es-ES')}: ${title}`)
          })
          : console.log('No commits found')
      })
    })
}

main()
