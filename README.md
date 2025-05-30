# Memoria-App-Cultura

## Descripción

*Memoria y aplicación multiplataforma para eventos culturales*

Este proyecto presenta una aplicación multiplataforma diseñada para facilitar el acceso a eventos culturales gratuitos. Su objetivo es ofrecer una herramienta intuitiva y práctica que permita a los usuarios:

- *Explorar* eventos por ciudad y categoría.
- *Guardar* eventos favoritos y gestionar sus inscripciones.
- *Filtrar* los resultados según ubicación y tipo de actividad.
- *Descubrir* nuevas propuestas culturales usando datos abiertos de Madrid y Barcelona.

La aplicación está construida con *Flutter* en el cliente y un backend en *Java 17* con *Spring Boot* y *MySQL*, todo orquestado en contenedores Docker. La arquitectura desacoplada garantiza escalabilidad y facilidad de mantenimiento. Se implementa un API RESTful que abre la puerta a futuras ampliaciones, como notificaciones push y recomendaciones personalizadas. 

---

## Tecnologías utilizadas

- *Frontend:* Flutter (Dart) 
- *Backend:* Java 17, Spring Boot
- *Base de datos:* MySQL
- *Contenedores:* Docker, Docker Compose
- *APIs públicas consumidas:*
    - Datos abiertos Ayuntamiento de Madrid (CSV)
    - Datos abiertos Ayuntamiento de Barcelona (JSON)

---

## Requisitos previos

- *Git* instalado en tu sistema
- *Docker* y *Docker Compose*
- *Flutter SDK* (versión estable)
- *Java 17* y *Maven* (o Gradle)

---

## Instalación y ejecución

1. Clona el repositorio:
   git clone https://github.com/tu-usuario/memoria-app-cultura.git
   cd memoria-app-cultura

2. Levanta los servicios con Docker Compose:
   docker-compose up --build

3. En otra terminal, ejecuta el backend:
   cd backend
   mvn spring-boot:run

4. Ejecuta el frontend Flutter:
   cd frontend
   flutter pub get
   flutter run


---

## Uso

- Accede desde un dispositivo móvil o navegador web (por defecto en http://localhost:8080).
- Navega por las categorías y ciudades para explorar eventos.
- Haz clic en un evento para ver detalles y registrarte.

---

## Licencia

Este proyecto está bajo la licencia MIT