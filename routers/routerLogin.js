"use strict";

const middlewares       = require('../middlewares');
const express           = require('express');
const loginRouter       = express.Router();
const controller        = require('../controllers/controllerLogin');
const bodyParser        = require('body-parser');
const multer            = require('multer');
const path              = require('path');
const multerFactory     = multer({ dest : path.join(__dirname, "../uploads") }); // Otro codificador de forms como body-parser pero para imagenes

// middleware
loginRouter.use(bodyParser.urlencoded({ extended: false }));


// Vistas
loginRouter.get("/registro", controller.getRegisterRedirect);
loginRouter.get("/login", controller.getLoginRedirect);

// Forms/acciones de las vistas
loginRouter.post("/registrarUsuario", multerFactory.single("img"), controller.registerUser);
loginRouter.post("/loginUser", controller.loginUser);
loginRouter.get("/logoutUser", middlewares.checkSession, controller.logoutUser);


loginRouter.use(middlewares.middlewareNotFoundError); // middleware ERROR 404
loginRouter.use(middlewares.middlewareServerError); // middleware ERROR 500

module.exports = loginRouter;