"use strict";

const middlewares       = require('../middlewares');
const express           = require('express');
const mensajesRouter    = express.Router();
const controller        = require('../controllers/controllerMensajes');
const bodyParser        = require('body-parser');
const multer            = require('multer');
const path              = require('path');


// middleware
mensajesRouter.use(bodyParser.urlencoded({ extended: false }));

mensajesRouter.use(middlewares.checkSession);
// Vistas
mensajesRouter.get("/", controller.getAllMessages);// ruta para coger todos los mensajes de un usuario
mensajesRouter.get("/crearMensaje",controller.readuserMensajes);// para la vista de crearMensaje
mensajesRouter.get("/borrar/:idUser",controller.borrarMensajes);// para borrar un mensaje


mensajesRouter.post("/enviar",controller.enviarMensaje);//post con el mensaje




mensajesRouter.use(middlewares.middlewareNotFoundError); // middleware ERROR 404
mensajesRouter.use(middlewares.middlewareServerError); // middleware ERROR 500


module.exports = mensajesRouter;