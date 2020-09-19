



var database = firebase.database();
database.ref().child("/sensor").once('value', function(snapshot)

{
    if(snapshot.exists()){
        var content = '';
            snapshot.forEach(function(data){
                var val = data.val();
                content +='<tr>';
                content += '<th>' + val.BPM+ '</th>';
                
                  content += '<th>' + val.temp + '</th>';
                 
                
                
                
                content += '</tr>';
                 
          });
            $('#ex-table').append(content);
            console.log(snapshot.val());
        }
  });




