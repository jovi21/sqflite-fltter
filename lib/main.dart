
import 'package:app_crud_sqlite/database.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home>{
  List<Nombre> _list;
  DatabaseHelper _databaseHelper;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add), 
            onPressed: (){
              insert(context);
            },
          ),
        ],
      ),
      body: _getBody(),
    );
  }

  void insert(BuildContext context){
    Nombre nNombre = new Nombre();
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Nuevo"), 
          content: TextField(onChanged: (value){
            nNombre.title = value;
          }, decoration: InputDecoration(labelText: "Título:"),),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"), 
              onPressed: () {
                Navigator.of(context).pop();
              }
            ),
            FlatButton(
              child: Text("Save"), 
              onPressed: () {
                _databaseHelper.insert(nNombre);
                Navigator.of(context).pop();
                update();
              }
            ),
          ],
        );
      }
    );
  }

  void onDeleteRequest(int index){
    Nombre nombre = _list[index];
    setState(() {
      _databaseHelper.delete(nombre).then((onValue){
        setState(() {
          _list.removeAt(index);
        });
      });
    });
  }

  void onUpdateRequest(int index){
    Nombre nNombre = _list[index];
    final controller = TextEditingController(text: nNombre.title);
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Modificar"), 
          content: TextField(controller: controller,
            onChanged: (value){
              nNombre.title = value;
            }, 
            decoration: InputDecoration(labelText: "Título:"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"), 
              onPressed: () {
                Navigator.of(context).pop();
              }
            ),
            FlatButton(
              child: Text("Update"), 
              onPressed: () {
                _databaseHelper.update(nNombre);
                Navigator.of(context).pop();
                update();
              }
            ),
          ],
        );
      }
    );
  }

  Widget _getBody(){
    if(_list == null){
      return CircularProgressIndicator();
    }else if(_list.length == 0){
      return Text("Vacio");
    }else{
      return ListView.builder(
        itemCount: _list.length, 
        itemBuilder: (BuildContext context, index){
          Nombre nombre = _list[index];
          return NombreWidget(nombre, onDeleteRequest, index, onUpdateRequest);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _databaseHelper = new DatabaseHelper();
    update();
  }

  void update(){
    _databaseHelper.getList().then((resultList){
      setState(() {
        _list = resultList;
      });
    });
  }
}

typedef OnDelete = void Function(int index);
typedef OnUpdate = void Function(int index);

class NombreWidget extends StatelessWidget{
  final Nombre nombre;
  final OnDelete onDelete;
  final OnUpdate onUpdate;
  final int index;
  NombreWidget(this.nombre, this.onDelete, this.index, this.onUpdate);
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("${nombre.id}"),
      child: Padding(
        padding: EdgeInsets.all(10), 
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(nombre.title),
            ),
            IconButton(
              icon: Icon(
                Icons.edit, 
                size: 30,
              ), 
              onPressed: () {
                this.onUpdate(index);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete, 
                size: 30,
              ), 
              onPressed: () {
                this.onDelete(index);
              },
            )
          ],
        )
      ),
      onDismissed: (direction){
        onDelete(this.index);
      },
    );
  }
}