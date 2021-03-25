"use strict";

const middlewares   = require('../middlewares');
const express       = require('express');
const usersRouter   = express.Router();
const controller    = require('../controllers/controllerUsuarios');

// Middlewares
usersRouter.use(middlewares.checkSession);

// Vistas y acciones
usersRouter.get("/", controller.getAllUsers);
usersRouter.get("/filtrar", controller.findByFilter);
usersRouter.get("/perfil/:id", controller.findByID);

usersRouter.use(middlewares.middlewareNotFoundError); // middleware ERROR 404
usersRouter.use(middlewares.middlewareServerError); // middleware ERROR 500

module.exports = usersRouter;