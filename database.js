'use strict'

const config    = require('./config');
const mysql     = require ('mysql');
const pool      = mysql.createPool({
    host        : config.mysqlConfig.host,
    user        : config.mysqlConfig.user,
    password    : config.mysqlConfig.password,
    database    : config.mysqlConfig.database,
    multipleStatements: true
});

module.exports = pool;

