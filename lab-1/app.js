const express = require('express')
const app = express()
// const port = 3000
const util = require('util')

app.get('/', (req, res) => {
   res.setHeader('Content-Type', 'text/plain')
   res.end(util.format("%s-%s",new Date(),"Got HTTP Get Request"));
})

app.listen(process.env.PORT || 3000, () => {
  console.log(`Example app listening on port ${process.env.PORT || 3000}`)
})
