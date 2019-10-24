
var functions = require('firebase-functions');
var admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendNotification = functions.database.ref('/ReplyOnPost/{id}')
    .onWrite(event => {

        // Grab the current value of what was written to the Realtime Database.
        var eventSnapshot = event.data;
        var str1 = "Author is ";
        // var str = str1.concat(eventSnapshot.child("author").val());
        console.log(str1);

        // var topic = "android";
        var payload = {
            data: {
                title: "Test",
                author: "lioBOB"
            }
        };

        // Send a message to devices subscribed to the provided topic.
        // return admin.messaging().sendToTopic(topic, payload)
        //     .then(function (response) {
        //         // See the MessagingTopicResponse reference documentation for the
        //         // contents of response.
        //         console.log("Successfully sent message:", response);
        //         return null;
        //     })
        //     .catch(function (error) {
        //         console.log("Error sending message:", error);
        //         return null;
        //     });

        return admin.database().ref('NotificationId').once('value').then(allToken =>{
            if (allToken.val()){
                const token = Object.keys(allToken.val());
                return admin.messaging().sendToDevice(token, payload).then(response =>{
                    return null
                });
            }else{
                    return null

            }

        });
    });
