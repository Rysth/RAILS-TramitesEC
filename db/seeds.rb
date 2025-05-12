# Seed Users
User.create(username: "William Briones", email: "william.b@tramitesec.cloud", password: "TramitesEC@William", is_admin: true,  active: true)
User.create(username: "Ericka Contreras", email: "ericka.c@tramitesec.cloud", password: "TramitesEC@Ericka", is_admin: false,  active: true)
User.create(username: "Gabriela Sanchéz", email: "gabriela.s@tramitesec.cloud", password: "TramitesEC@Gabriela", is_admin: false, active: true)

# Additional Users
User.create(username: "Carlos Mendez", email: "carlos.m@tramitesec.cloud", password: "TramitesEC@Carlos", is_admin: false, active: true)
User.create(username: "Maria Torres", email: "maria.t@tramitesec.cloud", password: "TramitesEC@Maria", is_admin: false, active: true)

# Seed Agencies
Agency.create(code: "ANT-001", name: "Agencia Nacional de Tránsito Guayaquil", has_licenses: true, active: true)
Agency.create(code: "ATM-001", name: "Autoridad de Tránsito Municipal Guayaquil", has_licenses: false, active: true)
Agency.create(code: "CTE-001", name: "Comisión de Tránsito del Ecuador", has_licenses: true, active: true)
Agency.create(code: "ANT-002", name: "Agencia Nacional de Tránsito Quito", has_licenses: true, active: true)
Agency.create(code: "ANT-003", name: "Agencia Nacional de Tránsito Cuenca", has_licenses: true, active: true)

# Seed ProcedureTypes
ProcedureType.create(name: "Revisión", active: true, has_licenses: false) # || Vehicular
ProcedureType.create(name: "Renovación", active: true, has_licenses: true ) # Licencia
ProcedureType.create(name: "Título", active: true, has_licenses: true)  # Cursos Manejo (Primera Vez) # Licencia
ProcedureType.create(name: "Ingreso Títulos", active: true, has_licenses: true) # Casos de Usuarios Directos # Licencia
ProcedureType.create(name: "Recuperación de Puntos", active: true, has_licenses: true) # Licencia
ProcedureType.create(name: "Duplicado AAA", active: true, has_licenses: true) # Licencia
ProcedureType.create(name: "Duplicado de Licencia Original", active: true, has_licenses: true) # Licencia
ProcedureType.create(name: "Desbloqueo de Licencia", active: true, has_licenses: true) # Licencia
ProcedureType.create(name: "Licencia Anclada", active: true, has_licenses: true) # Licencia
ProcedureType.create(name: "Actualización de Datos", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Observación Laminas Oscuras", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Certificados sin Deuda", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Certificados con Deuda", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Revisión Transporte Público", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Cambio de Propietario", active: true, has_licenses: true) # Vehicular y Liceni
ProcedureType.create(name: "Cambio de Color", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Gravamen", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Revisión ATM Particulares", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Cambio de Comercial/Particular", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Ingreso de Vehículo", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Tipo de Sangre", active: true, has_licenses: true) # Licencia
ProcedureType.create(name: "CUV", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Revisión Técnica", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Duplicado de Placa", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Duplicado de Matrícula", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Especie de Matrícula", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Cambio de Características", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Cambio de Motor", active: true, has_licenses: false) # Vehicular
ProcedureType.create(name: "Psicosensométrico", active: true, has_licenses: false) # Vehicular

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
License.create(name: "F", active: true, license_type_id: 3)

# Seed Statuses
Status.create(name: "En Proceso")
Status.create(name: "Entregado Proveedor")
Status.create(name: "Envíado Brevetar") # Ej: Es un ingreso (Renovación, significa que me entrego una documentación) Paso Opcional va en relación con el Usuario Directo
Status.create(name: "Entregado Cliente")

# Seed Payments
PaymentType.create(name: "Efectivo")
PaymentType.create(name: "Transferencia Bancaria")
PaymentType.create(name: "Depósito")

# Seed Processors (associated with User)
# Linking to existing users
Processor.create(
  first_name: "Roberto", 
  last_name: "Jimenez", 
  phone: "0987654321", 
  active: true, 
  user_id: User.find_by(username: "Carlos Mendez").id
)
Processor.create(
  first_name: "Andrea", 
  last_name: "Morales", 
  phone: "0998765432", 
  active: true, 
  user_id: User.find_by(username: "Maria Torres").id
)
Processor.create(
  first_name: "Luis", 
  last_name: "Vega", 
  phone: "0976543210", 
  active: true, 
  user_id: User.find_by(username: "Gabriela Sanchéz").id
)

# Seed Suppliers
Supplier.create(
  identification: "0912345678", 
  name: "Autopartes Ecuador S.A.", 
  phone: "042123456", 
  email: "info@autopartesec.com", 
  active: true, 
  user_id: User.find_by(username: "William Briones").id
)
Supplier.create(
  identification: "0923456789", 
  name: "Trámites Rápidos", 
  phone: "042234567", 
  email: "contacto@tramitesrapidos.com", 
  active: true, 
  user_id: User.find_by(username: "Ericka Contreras").id
)
Supplier.create(
  identification: "0934567890", 
  name: "Gestión Vehicular", 
  phone: "042345678", 
  email: "gestion@vehicularec.com", 
  active: true, 
  user_id: User.find_by(username: "William Briones").id
)

# Seed Customers
# Direct customers (not associated with a processor)
5.times do |i|
  Customer.create(
    identification: "09#{rand(10000000..99999999)}",
    first_name: ["Juan", "Pedro", "Ana", "Sofia", "Julio"].sample,
    last_name: ["Perez", "Gonzalez", "Rodriguez", "Castro", "Alvarez"].sample,
    phone: "09#{rand(10000000..99999999)}",
    email: "cliente#{i+1}@mail.com",
    address: "Av. Principal #{i+1}, Guayaquil",
    is_direct: true,
    active: true,
    user_id: User.all.sample.id
  )
end

# Customers associated with processors
processors = Processor.all
10.times do |i|
  Customer.create(
    identification: "09#{rand(10000000..99999999)}",
    first_name: ["Maria", "Carlos", "Lucia", "Jorge", "Diana", "Fernando", "Patricia", "David", "Elena", "Roberto"].sample,
    last_name: ["Mendez", "Torres", "Garcia", "Lopez", "Martinez", "Ruiz", "Sanchez", "Flores", "Morales", "Ortiz"].sample,
    phone: "09#{rand(10000000..99999999)}",
    email: "cliente_proc#{i+1}@mail.com",
    address: "Calle #{i+1} y Avenida Principal, Guayaquil",
    is_direct: false,
    active: true,
    user_id: User.all.sample.id,
    processor_id: processors.sample.id
  )
end

# Seed Procedures
customers = Customer.all
procedure_types = ProcedureType.all
statuses = Status.all
agencies = Agency.all
suppliers = Supplier.all
license_types = ProcedureType.where(has_licenses: true)
licenses = License.all

# Create 30 sample procedures
30.times do |i|
  # Select a random procedure type
  procedure_type = procedure_types.sample
  # Select an appropriate license if the procedure type requires one
  license_id = procedure_type.has_licenses ? licenses.sample.id : nil
  # Calculate some realistic financial values
  cost = rand(50.0..500.0).round(2)
  payment_amount = rand(0..cost).round(2)
  cost_pending = cost - payment_amount
  profit = (cost * 0.3).round(2)  # 30% profit margin
  profit_pending = (cost_pending * 0.3).round(2)
  supplier_amount = rand(0.0..cost * 0.5).round(2) # Supplier gets up to 50% of cost
  
  # Create the procedure
  procedure = Procedure.create(
    code: "TM-#{format('%06d', i+1)}",
    date: Date.today - rand(0..60),
    plate: [nil, "G#{('A'..'Z').to_a.sample}#{('A'..'Z').to_a.sample}-#{rand(1000..9999)}"].sample,
    cost: cost,
    cost_pending: cost_pending,
    profit: profit,
    profit_pending: profit_pending,
    comments: ["Trámite urgente", "Cliente recurrente", "Documentación completa", "Requiere seguimiento", nil].sample,
    is_paid: payment_amount == cost,
    active: true,
    user_id: User.all.sample.id,
    processor_id: customers.sample.processor_id,
    customer_id: customers.sample.id,
    procedure_type_id: procedure_type.id,
    status_id: statuses.sample.id,
    license_id: license_id,
    supplier_amount: supplier_amount,
    supplier_id: suppliers.sample.id,
    agency_id: agencies.sample.id
  )
  
  # Create a payment record if there was some payment
  if payment_amount > 0
    Payment.create(
      date: procedure.date,
      value: payment_amount,
      receipt_number: "REC-#{format('%06d', i+1)}",
      payment_type_id: PaymentType.all.sample.id,
      procedure_id: procedure.id
    )
  end
end

puts "Seeds completed successfully!"
