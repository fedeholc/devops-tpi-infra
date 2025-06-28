-- db v0.3

-- Evitar conflictos de claves externas al recrear
SET FOREIGN_KEY_CHECKS = 0;

-- Eliminar tablas si existen
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS PedidoDisponibilidad;
DROP TABLE IF EXISTS PedidoCandidatos;
DROP TABLE IF EXISTS Pedido;
DROP TABLE IF EXISTS TecnicoAreas;
DROP TABLE IF EXISTS Tecnico;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Usuario;
DROP TABLE IF EXISTS Areas;

-- Crear tablas base
CREATE TABLE Areas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    descripcion TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci UNIQUE,
    password VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    rol ENUM('cliente', 'tecnico', 'admin')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Cliente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT,
    nombre VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    apellido VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    telefono VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    direccion VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    fechaRegistro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Tecnico (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT,
    nombre VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    apellido VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    telefono VARCHAR(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    direccion VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    caracteristicas TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    fechaRegistro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE TecnicoAreas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tecnicoId INT,
    areaId INT,
    FOREIGN KEY (tecnicoId) REFERENCES Tecnico(id),
    FOREIGN KEY (areaId) REFERENCES Areas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de pedidos
CREATE TABLE Pedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    clienteId int,
    tecnicoId int, 
    estado ENUM('sin_candidatos', 'con_candidatos', 'tecnico_seleccionado', 'cancelado', 'finalizado', 'calificado') DEFAULT 'sin_candidatos',
    areaId int,
    requerimiento TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    calificacion int, -- del 1 al 5?
    comentario TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,-- calificaión-comentario 
    respuesta TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci, -- feedback del tecnico
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fechaCierre DATETIME,
    fechaCancelado DATETIME, -- cancelado por el cliente 
    FOREIGN KEY (clienteId) REFERENCES Cliente(id),
    FOREIGN KEY (tecnicoId) REFERENCES Tecnico(id),
    FOREIGN KEY (areaId) REFERENCES Areas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de disponibilidad que dan los clientes 
CREATE TABLE PedidoDisponibilidad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedidoId int,
    clienteId int,
    dia ENUM('lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'),
    horaInicio TIME,
    horaFin TIME,
    FOREIGN KEY (clienteId) REFERENCES Cliente(id),
    FOREIGN KEY (pedidoId) REFERENCES Pedido(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de candidatos a un pedido
CREATE TABLE PedidoCandidatos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedidoId int,
    tecnicoId int,
    FOREIGN KEY (pedidoId) REFERENCES Pedido(id),
    FOREIGN KEY (tecnicoId) REFERENCES Tecnico(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

 
-- Tabla de facturas
CREATE TABLE Factura (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    total INT,
    metodoPago ENUM('tarjeta', 'transferencia'),
    FOREIGN KEY (usuarioId) REFERENCES Usuario(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reactivar claves foráneas
SET FOREIGN_KEY_CHECKS = 1;
