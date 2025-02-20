import 'package:flutter/material.dart'; //Importa la biblioteca principal de Flutter, que proporciona los widgets esenciales para construir la interfaz gráfica.
import 'dart:async'; //Importa la biblioteca de utilidades necesaria para usar Timer, que controla la actualización del juego.
import 'dart:math'; //Importa la biblioteca matemática, usada para generar números aleatorios (posición de la comida de la serpiente).

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  //MyApp es el widget principal de la app. Extiende StatelessWidget, su estado no cambia después de la construcción.
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la barra de depuración
      home:
          HomePage(), //home: HomePage() establece HomePage como la pantalla inicial.
    );
  }
}

class HomePage extends StatefulWidget {
  //HomePage es un StatefulWidget, significa que su estado puede cambiar.
  @override
  _HomePageState createState() =>
      _HomePageState(); //createState() crea una instancia de _HomePageState, que maneja la lógica del juego.
}

class _HomePageState extends State<HomePage> {
  //Contiene la lógica del juego, incluyendo el movimiento de la serpiente y la detección de colisiones.

  static List<int> snakePosition = [
    45,
    65,
    85,
    105,
    125
  ]; // Posiciones iniciales de la serpiente
  int numberOfSquares = 760; // Número total de celdas en la cuadrícula (20x38)

  static var randomNumber = Random();
  int food = randomNumber.nextInt(700); // Posición inicial de la comida

  // Método para generar nueva comida evitando la posición de la serpiente
  void generateNewFood() {
    setState(() {
      do {
        food = randomNumber.nextInt(numberOfSquares);
      } while (snakePosition.contains(food));
    });
  }

  // Método para iniciar el juego
  void startGame() {
    snakePosition = [
      45,
      65,
      85,
      105,
      125
    ]; // Reinicia la posición de la serpiente
    const duration = const Duration(
        milliseconds:
            200); // Velocidad de actualización (velocidad de la serpiente)
    Timer.periodic(duration, (Timer timer) {
      updateSnake(); // Actualiza la posición de la serpiente
      if (gameOver()) {
        //Si hay colisión, se cancela el temporizador y se muestra la pantalla de "Game Over".
        timer.cancel(); // Detiene el juego si hay colisión
        _showGameOverScreen();
      }
    });
  }

  var direction = 'down'; // Dirección inicial de la serpiente (hacia abajo)

  // Método para actualizar la posición de la serpiente
  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down': //si la serpiente sale de la pantalla hacia abajo, reaparece en la parte de arriba
          if (snakePosition.last > 740) {
            snakePosition
                .add(snakePosition.last + 20 - 760); // Teletransporta arriba
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;
        case 'up': //si la serpiente sale de la pantalla hacia arriba, reaparece en la parte de abajo
          if (snakePosition.last < 20) {
            snakePosition
                .add(snakePosition.last - 20 + 760); // Teletransporta abajo
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        case 'left': //si la serpiente sale de la pantalla hacia la izquierda, reaparece en la derecha
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(
                snakePosition.last - 1 + 20); // Teletransporta a la derecha
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right': //si la serpiente sale de la pantalla hacia la derecha, reaparece en la parte izquierda
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(
                snakePosition.last + 1 - 20); // Teletransporta a la izquierda
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
      }

      // Si la serpiente coincide con la comida se genera una comida nueva
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        snakePosition.removeAt(0); // si no, se acorta la cola
      }
    });
  }

  // Método para verificar colisión de la serpiente consigo misma
  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count += 1;
        }
        if (count == 2) {
          return true; // Si hay colisión, termina el juego
        }
      }
    }
    return false;
  }

  // Método para mostrar la pantalla de "Game Over"
  void _showGameOverScreen() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GAME OVER'),
            content: Text('Tu puntuación:   ${snakePosition.length - 5}'),
            actions: <Widget>[
              TextButton(
                child: Text('Jugar de nuevo'),
                onPressed: () {
                  startGame(); // Reinicia el juego
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              //GestureDetector detecta deslizamientos y cambia la dirección de la serpiente.
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: Container(
                child: GridView.builder(
                    //Se usa GridView.builder para dibujar la cuadrícula.
                    physics:
                        NeverScrollableScrollPhysics(), //physics: NeverScrollableScrollPhysics() evita que la cuadrícula sea desplazable.
                    itemCount: numberOfSquares,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            20), //crossAxisCount: 20 establece que la cuadrícula tenga 20 columnas.
                    itemBuilder: (BuildContext context, int index) {
                      if (snakePosition.contains(index)) {
                        //Si el índice index está en snakePosition, significa que la celda es parte de la serpiente.
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(
                                2), //Relleno interno de dos pixeles a la serpiente
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  5), //Se dibuja un cuadrado blanco (color: Colors.white) con bordes redondeados (borderRadius).
                              child: Container(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      if (index == food) {
                        //Si index coincide con la posición de la comida, se dibuja un cuadrado verde (color: Colors.green).
                        return Container(
                          padding: EdgeInsets.all(
                              2), //Relleno interno de dos pixeles a la comida
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(color: Colors.green)),
                        );
                      } else {
                        //Si index no es la serpiente ni la comida, se dibuja un cuadrado gris oscuro (color: Colors.grey[900]), representando el fondo de la cuadrícula.
                        return Container(
                          padding: EdgeInsets.all(
                              2), // Relleno interno de dos pixeles a la cuadricula de fondo
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(color: Colors.grey[900])),
                        );
                      }
                    }),
              ),
            ),
          ),
          Padding(
            //Se usa Padding para agregar espacio en la parte inferior y los lados.
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              //Row organiza los elementos horizontalmente.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  //GestureDetector permite que el texto "s t a r t" actúe como botón de inicio del juego.
                  onTap:
                      startGame, //onTap: startGame inicia el juego cuando se toca el texto.
                  child: Text(
                    's t a r t',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Text(
                  //Texto con las iniciales del autor del juego
                  '@ E K R L',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ) //Text
              ], //<Widget>
            ), //Row
          ) //Padding
        ], //<Widget>
      ), //Column
    ); //Scaffold
  }
}
