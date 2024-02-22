import React, { useState, useEffect } from 'react';
import './App.css';

const App = () => {
  const [nombre, setNombre] = useState('');
  const [carnet, setCarnet] = useState('');
  const [fechaHora, setFechaHora] = useState('');

  useEffect(() => {
    const actualizarFechaHora = () => {
      const now = new Date();
      const fechaHoraString = now.toLocaleString();
      setFechaHora(fechaHoraString);
    };

    const intervalo = setInterval(actualizarFechaHora, 1000);

    return () => clearInterval(intervalo);
  }, []);

  return (
    <div className="container">
      <label className="label">
        Nombre: Luis David Garcia Alay
      </label>
      <label className="label">
        Carnet: 201612511
      </label>
      <p className="info">Fecha y Hora actual: {fechaHora}</p>
    </div>
  );
};

export default App;