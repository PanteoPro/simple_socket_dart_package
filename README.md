# Simple Socket Dart

## Description


This package allows you to create a client/server connection to transfer simple data.

## Getting started

There are two entities in this package SimpleSocketServer and SimpleSocketClient, server and client respectively.

### Server creation
```dart
final server = SimpleSocketServer();
await server.start(ip: '127.0.0.1', port: 7777);
```

### Client creation
```dart
final client = SimpleSocketClient();
await client.connect(ip: '127.0.0.1', port: 7777);
```

## Usage

The example below shows how to transfer and recieve data between client and server.

### Server side
```dart
late final SimpleSocketServer server;
server = SimpleSocketServer(
    onServerStarted: () {
      print(
          'SERVER: Server started at ${server.ipServer}:${server.portServer}');
    },
    onConnectedClient: (client) {
      print(
          'SERVER: Client ${client.remoteAddress.address}:${client.remotePort} connected');
    },
    onDataClient: (Socket client, List<String> messages) {
        // When receiving data from a client
        print(messages);
    },
    onErrorClient: (Socket client, dynamic error){
        print('An error occurred on the client - $error');
    },
    onDoneClient: (Socket client){
        print('When the client successfully closed the connection');
    }
);
await server.start(ip: '127.0.0.1', port: 7777);

// Send to all client the message
server.sendMessages({"data": "Hello world clients"});

// Get the first connection (client)
final client = server.socketClients.first;
// Send to specific client message
server.sendMessage(client, {"data": "Hello my dear friend"});

// Close the server
server.close();
```

### Client side
```dart
late final SimpleSocketClient client;
client = SimpleSocketClient(
    onConnectedServer: () {
      print('Connected to ${client.ipServer}:${client.portServer}');
    },
    onDataServer: (List<String> messages) {
        // When recieved data from server
        print(messages);
    },
    onErrorServer: (dynamic error) {
        print('An error occured on the server - $error');
    },
    onDoneServer: (){
        print('When the server successfully closed');
    }
);
await client.connect(ip: '127.0.0.1', port: 7777);

// Send message to the server
client.sendMessage({"data": "Hello server"});

// Close the client connection
client.close();
```
