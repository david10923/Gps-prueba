"use strict";

const middlewares       = require('../middlewares');
const express           = require('express');
const questionsRouter   = express.Router();
const controller        = require('../controllers/controllerPreguntas');
const bodyParser        = require('body-parser');

// middleware
questionsRouter.use(bodyParser.urlencoded({ extended: false }));
questionsRouter.use(middlewares.checkSession);

// Vistas y forms/acciones de las vistas
questionsRouter.get("/", controller.getAllQuestions);
questionsRouter.get("/etiquetas/:label", controller.findByTag);
questionsRouter.get("/formular", controller.formulate);
questionsRouter.get("/buscar", controller.findByFilter);
questionsRouter.get("/:id", controller.getQuestion);
questionsRouter.post("/formulateQuestion", controller.formulateQuestion);
questionsRouter.post("/publicarRespuesta/:id", controller.postAnswer);
questionsRouter.get("/like/:id", controller.scoreQuestion);
questionsRouter.get("/dislike/:id", controller.scoreQuestion);
questionsRouter.get("/descargar/sinresponder", controller.noAnswers);
questionsRouter.get("/respuestas/like/:idQ/:idA", controller.scoreAnswer);
questionsRouter.get("/respuestas/dislike/:idQ/:idA", controller.scoreAnswer);

questionsRouter.use(middlewares.middlewareNotFoundError); // middleware ERROR 404
questionsRouter.use(middlewares.middlewareServerError); // middleware ERROR 500

module.exports = questionsRouter;