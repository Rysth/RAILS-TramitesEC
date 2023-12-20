# Seed Users
User.create(username: "John Palacios", email: "admin@test.com", password: "123456")
User.create(username: "Ericka Briones", email: "ericka.b@test.com", password: "123456")
User.create(username: "William Briones", email: "william.b@test.com", password: "123456")
User.create(username: "Gabriela Sanchéz", email: "gabriela.s@test.com", password: "123456")

# Seed Roles
Role.create(nombre: "Administrator", slug: "admin")
Role.create(nombre: "Trámitador", slug: "processor")
Role.create(nombre: "Cliente", slug: "customer")

# Seed Clientes with Faker data
5.times do
  Cliente.create(
    cedula: Faker::IDNumber.unique.spanish_citizen_number,
    nombres: Faker::Name.first_name,
    apellidos: Faker::Name.last_name,
    celular: Faker::PhoneNumber.cell_phone,
    direccion: Faker::Address.street_address,
    email: Faker::Internet.email,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    user_id: User.ids.sample,
    role_id: Role.ids.sample
  )
end
