var database = firebase.database();
database.ref().child('/messages').once('value', function(snapshot)

{
    if(snapshot.exists()){
        var content = '';
            snapshot.forEach(function(data){
                var val = data.val();
                content +='<tr>';
                content += '<th>' + val.name+ '</th>';
                content += '<th>' + val.email + '</th>';
                  content += '<th>' + val.hospital + '</th>';
                  content += '<th>' + val.phone + '</th>';
                content += '<th>' + val.message + '</th>';
                
                
                content += '</tr>';
                 
          });
            $('#ex-table').append(content);
            console.log(snapshot.val());
        }
  });