#!/usr/bin/env node
const got = require('got')
const cheerio = require('cheerio')

const PROJECTS = [
  {
    name: 'Superdesk Core',
    regex: 'SDESK',
  },
  {
    name: 'Belga',
    regex: 'SDBELGA',
  },
  {
    name: 'Fidelity',
    regex: 'SDFID',
  },
  {
    name: 'NTB',
    regex: 'SDNTB',
  },
  {
    name: 'Canadian Press',
    regex: 'SDCP',
  },
]

const padNumber = (n) => (n < 10 ? '0' + n : n.toString())

const getFromDate = (lastMonth = false) => {
  const minusOneMonth = lastMonth ? 1 : 0
  const now = new Date()
  const year =
    lastMonth && now.getMonth() === 0
      ? now.getFullYear() - 1
      : now.getFullYear()
  const month = year !== now.getFullYear() ? 11 : now.getMonth() - minusOneMonth
  const lastDayOfLastMonth = new Date(
    month === 0 ? year - 1 : year,
    month === 0 ? 11 : month,
    0
  ).getDate()
  const lastDayOfThisMonth = new Date(year, month + 1, 0).getDate()

  return `${month === 0 ? year - 1 : year}-${
    month === 0 ? 12 : padNumber(month)
  }-${padNumber(lastDayOfLastMonth)}`
}

async function search(since) {
  const url = `https://github.com/search?q=author%3Apablopunk+org%3Asuperdesk+created%3A%3E${since}&type=Issues`
  const res = await got(url)
  const $ = cheerio.load(res.body)
  const timeline = {}

  $('.issue-list-item').each((i, el) => {
    const branch = $(el).find('.text-mono').eq(1).text()
    const date = $(el).find('relative-time').attr('datetime').slice(0, 10)

    for (const project of PROJECTS) {
      if (new RegExp(project.regex).test(branch)) {
        if (timeline[date] != null && Array.isArray(timeline[date])) {
          timeline[date].push(project.name)
        } else {
          timeline[date] = [project.name]
        }
      }
    }
  })

  return timeline
}

async function main({ last = false } = {}) {
  const since = getFromDate(last)
  console.log(`From ${since} til today`)
  const timeline = await search(since)
  console.table(timeline)
}

let args = process.argv.slice(2)
args = args.reduce((acc, curr) => {
  acc[curr] = true
  return acc
}, {})
main(args)
