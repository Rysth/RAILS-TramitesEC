# Seed Users
User.create(username: "William Briones", email: "william.b@test.com", password: "123456", is_admin: true,  active: true)
User.create(username: "Ericka Contreras", email: "ericka.c@test.com", password: "123456", is_admin: false,  active: true)
User.create(username: "Gabriela Sanchéz", email: "gabriela.s@test.com", password: "123456", is_admin: false, active: true)


# Seed Processors with Faker data
50.times do
  Processor.create(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: Faker::Number.number(digits: 10),
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    user_id: User.ids.sample
  )
end

# Seed Clientes with Faker data
100.times do
  Customer.create(
    identification: Faker::Number.number(digits: 10),
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: Faker::Number.number(digits: 10),
    email: Faker::Internet.email,
    address: Faker::Address.street_address,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    is_direct: Faker::Boolean.boolean(true_ratio: 0.2),
    processor_id: Processor.ids.sample,
    user_id: User.ids.sample
  )
end

# Seed ProcedureTypes
ProcedureType.create(name: "Revisión", active: true, has_licenses: false)
ProcedureType.create(name: "Renovación", active: true, has_licenses: true )
ProcedureType.create(name: "Título", active: true, has_licenses: true)  # Cursos Manejo (Primera Vez)
ProcedureType.create(name: "Ingresos", active: true, has_licenses: true) # Casos de Usuarios Directos
ProcedureType.create(name: "Recuperación de Puntos", active: true, has_licenses: false)
ProcedureType.create(name: "Duplicado AAA", active: true, has_licenses: false)
ProcedureType.create(name: "Duplicado de Licencia Original", active: true, has_licenses: false)
ProcedureType.create(name: "Desbloqueo de Licencia", active: true, has_licenses: false)
ProcedureType.create(name: "Licencia Anclada", active: true, has_licenses: false)
ProcedureType.create(name: "Actualización de Datos", active: true, has_licenses: false)
ProcedureType.create(name: "Observación Laminas Oscuras", active: true, has_licenses: false)
ProcedureType.create(name: "Certificados sin Deuda", active: true, has_licenses: false)
ProcedureType.create(name: "Certificados con Deuda", active: true, has_licenses: false)
ProcedureType.create(name: "Revisión Transporte Público", active: true, has_licenses: false)
ProcedureType.create(name: "Cambio de Propietario", active: true, has_licenses: false)
ProcedureType.create(name: "Cambio de Color", active: true, has_licenses: false)
ProcedureType.create(name: "Gravamen", active: true, has_licenses: false)
ProcedureType.create(name: "Revisión ATM Particulares", active: true, has_licenses: false)
ProcedureType.create(name: "Cambio de Comercial/Particular", active: true, has_licenses: false)
ProcedureType.create(name: "Ingreso de Vehículo", active: true, has_licenses: false)
ProcedureType.create(name: "Tipo de Sangre", active: true, has_licenses: false)
ProcedureType.create(name: "CUV", active: true, has_licenses: false)

# Seed LicenseTypes
LicenseType.create(name: "No Profesionales", active: true)
LicenseType.create(name: "Profesionales", active: true)
LicenseType.create(name: "Especiales", active: true)

# Seed Licenses
License.create(name: "A", active: true, license_type_id: 1)
License.create(name: "B", active: true, license_type_id: 1)
License.create(name: "C", active: true, license_type_id: 2)
License.create(name: "D", active: true, license_type_id: 2)
License.create(name: "E", active: true, license_type_id: 2)
License.create(name: "A1", active: true, license_type_id: 3)
License.create(name: "C1", active: true, license_type_id: 3)
License.create(name: "E1", active: true, license_type_id: 3)
License.create(name: "G", active: true, license_type_id: 3)

# Seed Statuses
Status.create(name: "En Proceso")
Status.create(name: "Entregado Proveedor")
Status.create(name: "Envíado Brevetar") # Ej: Es un ingreso (Renovación, significa que me entrego una documentación) Paso Opcional va en relación con el Usuario Directo
Status.create(name: "Entregado Cliente")

# Seed Payments
PaymentType.create(name: "Efectivo")
PaymentType.create(name: "Transferencia Bancaria")
PaymentType.create(name: "Depósito")

250.times do
  customer = Customer.find(Customer.ids.sample)
  processor_id = customer.is_direct? ? nil : Processor.ids.sample

  procedure_type_id = ProcedureType.ids.sample
  procedure_type = ProcedureType.find(procedure_type_id)

  cost = Faker::Number.decimal(l_digits: 3)
  profit = Faker::Number.decimal(l_digits: 2)
  cost_pending = cost
  profit_pending = profit

  license_id = procedure_type.has_licenses? ? License.ids.sample : nil

  plate = procedure_type.id == 2 ? Faker::Vehicle.license_plate : nil

  procedure = Procedure.new(
    cost: cost,
    cost_pending: cost_pending,
    plate: plate,
    profit: profit,
    profit_pending: profit_pending,
    comments: Faker::Lorem.sentence,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    user_id: User.ids.sample,
    processor_id: processor_id,
    customer_id: customer.id,
    procedure_type_id: procedure_type_id,
    status_id: Status.ids.sample,
    license_id: license_id
  )

  if procedure.valid?
    procedure.save

    # Create payments and update cost_pending and profit_pending accordingly
    payment_value = procedure.cost
    while payment_value > 0
      payment_value -= procedure.cost_pending
      if payment_value >= 0
        procedure.cost_pending = 0
        procedure.profit_pending = 0
      else
        procedure.cost_pending -= payment_value.abs
        procedure.profit_pending -= payment_value.abs * (profit / cost)
      end

      payment_type_id = PaymentType.ids.sample
      receipt_number = payment_type_id == 1 ? nil : Faker::Invoice.reference
      
      Payment.create(
        value: payment_value > 0 ? procedure.cost_pending : payment_value.abs,
        receipt_number: receipt_number,
        payment_type_id: payment_type_id,
        procedure_id: procedure.id
      )
    end
  else
    puts "Procedure not valid: #{procedure.errors.full_messages}"
  end
end