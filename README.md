<div align="center">
  <h1>🗂️ TramitesEC - Backend API</h1>
  <p><strong>Sistema de Gestión de Trámites desarrollado con Ruby on Rails</strong></p>
  <p>
    <a href="https://www.rysthdesign.com">🌐 www.rysthdesign.com</a>
  </p>
</div>

---

## 📖 Acerca del Proyecto

**TramitesEC Backend** es una API REST robusta construida con Ruby on Rails, diseñada para gestionar trámites vehiculares y de licencias. Proporciona endpoints seguros para la administración de clientes, tramitadores, pagos y más.

---

## 🛠️ Tecnologías

| Tecnología | Descripción |
|------------|-------------|
| **Ruby on Rails 7** | Framework backend principal |
| **PostgreSQL** | Base de datos relacional |
| **Devise API** | Autenticación JWT |
| **Sidekiq + Redis** | Procesamiento de trabajos en segundo plano |
| **Docker** | Contenedorización para desarrollo y producción |

---

## ✨ Características Principales

- 🔐 **Autenticación segura** con tokens JWT y Devise
- 📊 **Gestión completa** de trámites, clientes y tramitadores
- 💰 **Control de pagos** y estados de trámites
- 📧 **Notificaciones automáticas** vía email con Sidekiq
- 📈 **Exportación de reportes** a Excel

---

## 🚀 Instalación

```bash
# Clonar el repositorio
git clone https://github.com/Rysth/RAILS-TramitesEC.git

# Con Docker (recomendado)
docker compose up -d

# Sin Docker
bundle install
rails db:setup
rails server
```

---

## 👤 Autor

**John Palacios** - Desarrollador Full Stack

[![Portfolio](https://img.shields.io/badge/Portfolio-rysthdesign.com-blue?style=flat-square)](https://www.rysthdesign.com)
[![GitHub](https://img.shields.io/badge/GitHub-Rysth-181717?style=flat-square&logo=github)](https://github.com/Rysth)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-John%20Palacios-0077B5?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/john-palacios-rysthcraft)

---

<div align="center">
  <p>📝 Licencia MIT © 2024-2026</p>
</div>
