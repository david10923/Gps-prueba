"use strict"

const moment = require('moment'); // Formatear fechas

class DAOMensajes{
    constructor(pool){
        this.pool = pool;
    }

    readAllMessages(params,callback){
        this.pool.getConnection(function(error,connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            }else{
                let sql= "SELECT u.id, u.username as usuarioOrigen , body , m.Date, u.profileImg as Img FROM mensajes m JOIN users u WHERE u.email=m.UserOrigin AND UserDest=? ORDER BY Date ASC;"
                connection.query(sql,[params],function(error,results){
                connection.release();
                    if(error){                       
                        callback(new Error("Error de acceso a la base de datos"));
                    }else{
                        results.forEach(result =>{
                            result.Date= moment(result.Date).format('YYYY-MM-DD HH:mm:ss');                               
                        });                          

                        callback(null,results);
                    }   
                });
            }
        });       

    }

    borrarMensaje(data,callback){
        this.pool.getConnection(function(error,connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            }else{
                let sql= "DELETE FROM mensajes WHERE UserOrigin=? AND userDest=?;";
                connection.query(sql,[data.usuarioMensaje,data.usuarioDestino],function(error,results){
                connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    }else{
                        callback(null,results);
                    }   
                });
            }
        });
       

    }

    

    readUserFriends(params,callback){
        this.pool.getConnection(function(error,connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            }else{
                let sql= '' ; 
                sql ="SELECT u.username, u.email , u.profileImg  FROM users u  ORDER BY username ASC;";       
                connection.query(sql, [params],function(error,results){
                connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    }else{                        

                        let data={};                      
                        data.usuarios = results;              
                        callback(null,data);
                    }   
                });
            }
        });
    }

    enviarMensaje(params,callback){
        this.pool.getConnection(function(error,connection){
            if(error){
                callback(new Error("Error de conexion a la base de datos"));
            }else{
                let sql = '';                
                sql= "INSERT INTO mensajes(`UserOrigin`, `UserDest`, `Body`) VALUES (?,?,?);";
                connection.query(sql,[params.usuarioOrigen,params.usuarioDestino,params.mensaje],function(error,results){
                connection.release();
                    if(error){
                        callback(new Error("Error de acceso a la base de datos"));
                    }else{
                        callback(null);
                    }   
                });
            }
        });

    }

}


module.exports = DAOMensajes;