"use strict"

// GENERAL
const middlewares       = require('./middlewares');
const bodyParser        = require('body-parser');
const express           = require('express');
const path              = require('path');
const morgan            = require('morgan');
const staticFiles       = path.join(__dirname, "public");
const usersRouter       = require("./routers/routerUsuarios");
const questionsRouter   = require('./routers/routerPreguntas');
const loginoutRouter    = require('./routers/routerLogin.js');
const session           = require('express-session');
const mysqlSession      = require('express-mysql-session');
const config            = require('./config');
const MySQLStore        = mysqlSession(session);
const mensajesRouter    = require('./routers//mensajesRouter.js');

const sessionStore      = new MySQLStore({
    host        : config.mysqlConfig.host,
    user        : config.mysqlConfig.user,
    password    : config.mysqlConfig.password,
    database    : config.mysqlConfig.database
});
const middlewareSession = session({
    saveUninitialized   : false,
    secret              : "DavidCarlos",
    resave              : false,
    store               : sessionStore 
});


// SERVER
const app = express();


// CONFIGURAR EJS COMO MOTOR DE PLANTILLAS Y DEFINIR EL DIRECTORIO DE LAS PLANTILLAS
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "./views"));


// MIDDLEWARES
app.use(express.static(staticFiles));
app.use(morgan('dev'));
app.use(middlewareSession); // middleware de session


// ROUTERS
app.use('/usuarios', usersRouter);
app.use('/preguntas', questionsRouter);
app.use('/loginout', loginoutRouter);
app.use('/mensajes',mensajesRouter);

// MANEJADORES DE RUTAS PRINCIPALES
app.get("/", (request, response) => {
    response.redirect("/index");
});

app.get("/index", middlewares.checkSession, (request, response) => {
    response.render("index");
});

app.get("/imagen/:id", middlewares.checkSession, function(request, response){
    response.sendFile(path.join(__dirname, "./uploads", request.params.id));
});

app.listen(config.port, function(error) {
    if (error) {
        console.error("No se pudo inicializar el servidor: " + error.message);
    } else {
        console.log(`Servidor arrancado en el puerto ${config.port}`);
    }
});

app.use(middlewares.middlewareNotFoundError); // middleware ERROR 404
app.use(middlewares.middlewareServerError); // middleware ERROR 500
