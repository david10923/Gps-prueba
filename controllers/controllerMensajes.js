"use strict";

const path          = require('path');
const { nextTick } = require('process');
const pool          = require("../database");
const DAOMensajes      = require('../models/modelsMensajes');
let daoMensajes        = new DAOMensajes(pool);
const middlewares       = require('../middlewares');
// probando la nueva config

module.exports ={

    getAllMessages: function(request, response,next){
        let usuarioDestino = request.session.currentEmail;        
        daoMensajes.readAllMessages(usuarioDestino,function(error, allUsers){
            if(error){
               next(error);
            } else{
                response.render("mensajes", {usuarios :allUsers});
            }
        });
    },

    // para borrar los mensajes de la BASE DE DATOS
    borrarMensajes: function(request, response,next){         
        let usuario ={
            usuarioDestino : request.session.currentEmail,
            usuarioMensaje : request.params.idUser  
        };
        console.log(usuario);

        daoMensajes.borrarMensaje(usuario,function(error, allUsers){
            if(error){
               next(error);
            } else{
                response.redirect("/mensajes/");
            }
        });
    },

    //VISTA DE ENVIAR MENSAJES
    readuserMensajes: function(request, response,next){
        let usuarioDestino = request.session.currentEmail;        
        daoMensajes.readUserFriends(usuarioDestino,function(error, data){
            if(error){
               next(error);
            } else{
                console.log(data.usuarios);
                response.render("enviarMensajes", {usuarios : data.usuarios });
            }
        });
    },


    // PARA ENVIAR LOS MENSAJES E INSERTARLO EN LA BD
    enviarMensaje: function(request, response,next){
       
        let info= {
            usuarioOrigen   :request.session.currentEmail,
            usuarioDestino  :request.body.usuarioDestino,
            mensaje         :request.body.mensaje
        };
        daoMensajes.enviarMensaje(info,function(error, data){
            if(error){
               next(error);
            } else{                
                response.redirect("/mensajes/crearMensaje")
            }
        });
    },


    



}