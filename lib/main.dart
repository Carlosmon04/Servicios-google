
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/firebase_options.dart';
import 'package:flutterfirebase/new_user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.getToken().then((token) {
      //TODO: guardar en firebase
      print('Token: $token');
    });

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Usuarios'),
      routes: {
        '/new_user': (context) => NewUserPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int? _draggedIndex; // Índice del perfil que está siendo arrastrado
  double _draggedPositionX = 0.0; // Posición X del perfil arrastrado
  @override
  Widget build(BuildContext context) {
    // final users = firestore.collection('usuarios').get();
    final users = firestore.collection('Users').snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final listaUsuarios = snapshot.data!.docs; // La lista de documentos
             
            return ListView.builder(
              itemCount: listaUsuarios.length,
              itemBuilder: (context, index) {
                final user = listaUsuarios[index];

                // user.id;

                  

     return GestureDetector(
            onHorizontalDragStart: (details) {
              // Al inicio del arrastre, registra el índice del perfil arrastrado
              setState(() {
                _draggedIndex = index;
              });
            },
            onHorizontalDragUpdate: (details) {
              if (_draggedIndex != null) {
                // Si hay un perfil arrastrado, actualiza su posición X
                setState(() {
                  _draggedPositionX += details.delta.dx;
                });
              }
            },
            onHorizontalDragEnd: (details) {
              // Al final del arrastre
              if (_draggedIndex != null) {
                // Verifica si el perfil se ha arrastrado más allá de cierto umbral (por ejemplo, 50% de la pantalla)
                if (_draggedPositionX.abs() > MediaQuery.of(context).size.width * 0.5) {
                 
                 print(user['nombre']);
           
           FirebaseFirestore.instance.collection('Users').where('nombre', isEqualTo:  user['nombre'])
           .get().then((QuerySnapshot){
            QuerySnapshot.docs.forEach((doc) {doc.reference.delete(); });
           });


           
                }
                // Reinicia el índice y la posición X
                setState(() {
                  _draggedIndex = null;
                  _draggedPositionX = 0.0;
                });
              }
            },
  child: Transform.translate(
     offset: Offset(index == _draggedIndex ? _draggedPositionX : 0, 0),
    child: ListTile(
      title: Text(user['nombre']),
      subtitle: Text(user['correo']),
      trailing: Text('${user['telefono']}'),
    ),
  ),
);



              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new_user');
        },
        tooltip: 'Nuevo usuario',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}