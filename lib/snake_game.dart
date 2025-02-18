import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la barra de depuración
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static List<int> snakePosition = [
    45,
    65,
    85,
    105,
    125
  ]; // Posiciones iniciales de la serpiente
  int numberOfSquares = 760; // Número total de celdas en la cuadrícula

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
    snakePosition = [45, 65, 85, 105, 125]; // Reinicia la serpiente
    const duration =
        const Duration(milliseconds: 100); // Velocidad de actualización
    Timer.periodic(duration, (Timer timer) {
      updateSnake(); // Actualiza la posición de la serpiente
      if (gameOver()) {
        timer.cancel(); // Detiene el juego si hay colisión
        _showGameOverScreen();
      }
    });
  }

  var direction = 'down'; // Dirección inicial de la serpiente

  // Método para actualizar la posición de la serpiente
  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > 740) {
            snakePosition
                .add(snakePosition.last + 20 - 760); // Teletransporta arriba
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;
        case 'up':
          if (snakePosition.last < 20) {
            snakePosition
                .add(snakePosition.last - 20 + 760); // Teletransporta abajo
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        case 'left':
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(
                snakePosition.last - 1 + 20); // Teletransporta a la derecha
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(
                snakePosition.last + 1 - 20); // Teletransporta a la izquierda
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
      }

      // Verifica si la serpiente ha comido
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        snakePosition.removeAt(0); // Movimiento normal de la serpiente
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
            content: Text('Your score: ' + snakePosition.length.toString()),
            actions: <Widget>[
              TextButton(
                child: Text('Play Again'),
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
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: numberOfSquares,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 20),
                    itemBuilder: (BuildContext context, int index) {
                      if (snakePosition.contains(index)) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      if (index == food) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(color: Colors.green)),
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.all(2),
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
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: startGame,
                  child: Text(
                    's t a r t',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Text(
                  'F o r  M a j o',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
