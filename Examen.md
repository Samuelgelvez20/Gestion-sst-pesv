# Proyecto académico

## Diseño e implementación de una base de datos para la gestión de SST y PESV utilizando PostgreSQL

# 1. Introducción

Las organizaciones actuales requieren sistemas de información que les permitan administrar de manera estructurada, segura y trazable los procesos asociados a la **Seguridad y Salud en el Trabajo (SST)** y al **Plan Estratégico de Seguridad Vial (PESV)**. Estos procesos involucran múltiples tipos de información, entre ellos organizaciones, trabajadores, cargos, documentos, módulos, formatos, evaluaciones, etapas de gestión y configuraciones específicas para cada empresa.

Cuando esta información se administra mediante archivos independientes, hojas de cálculo o documentos dispersos, pueden presentarse dificultades relacionadas con la duplicidad de datos, inconsistencias, falta de trazabilidad, pérdida de información y poca capacidad para generar indicadores de seguimiento.

Para resolver esta problemática se propone desarrollar una base de datos relacional utilizando **PostgreSQL**, orientada a soportar una plataforma de gestión de SST y PESV bajo un modelo **multi-tenant**, permitiendo que múltiples organizaciones utilicen el mismo sistema manteniendo sus datos separados lógicamente.

El modelo de datos contempla entidades relacionadas con empresas o `tenants`, personas, cargos, módulos, sistemas SST, plantillas, formatos, etapas del ciclo PHVA, evaluaciones, localización geográfica y mecanismos de control de edición. Asimismo, incorpora estructuras para la generación de información consolidada y seguimiento mediante vistas especializadas.

A través del desarrollo de este proyecto, los estudiantes aplicarán los conocimientos adquiridos sobre **modelado de bases de datos, normalización, lenguaje SQL, restricciones de integridad, relaciones entre tablas, consultas, vistas, procedimientos, funciones, triggers, índices y administración básica de PostgreSQL**.

El proyecto permitirá abordar un escenario similar a los utilizados en aplicaciones empresariales reales, fortaleciendo las competencias necesarias para diseñar soluciones de almacenamiento de datos robustas, escalables y mantenibles.

------

# 2. Planteamiento del problema

Una organización dedicada a prestar servicios de gestión de **Seguridad y Salud en el Trabajo y Plan Estratégico de Seguridad Vial** necesita desarrollar una plataforma tecnológica que pueda ser utilizada por diferentes empresas.

Cada empresa debe poder configurar su información de manera independiente, incluyendo:

- Datos generales de la organización.
- Tamaño de la empresa.
- Personas vinculadas.
- Cargos y responsabilidades.
- Sistemas de gestión habilitados.
- Módulos asociados al SST y PESV.
- Etapas del ciclo PHVA.
- Plantillas documentales.
- Formatos.
- Evaluaciones.
- Documentos generados.
- Seguimiento del avance.
- Ubicación geográfica.
- Control de edición de documentos.

Debido a que varias organizaciones utilizarán simultáneamente la plataforma, es necesario garantizar el aislamiento lógico de la información mediante una arquitectura de datos **multiempresa o multi-tenant**.

Además, la plataforma deberá permitir consultar el grado de avance de las empresas respecto a los documentos exigidos para cada etapa del proceso y facilitar la generación de indicadores de cumplimiento.

El principal problema consiste entonces en:

> **¿Cómo diseñar e implementar una base de datos relacional en PostgreSQL que permita gestionar de forma centralizada, segura, normalizada y escalable la información asociada a los procesos SST y PESV de múltiples organizaciones?**

------

# 3. Objetivo general

**Diseñar e implementar una base de datos relacional en PostgreSQL para soportar una plataforma multi-tenant de gestión de Seguridad y Salud en el Trabajo (SST) y Plan Estratégico de Seguridad Vial (PESV), aplicando técnicas de modelado, normalización, integridad referencial, programación SQL y optimización de consultas.**

------

# 4. Objetivos específicos

1. **Analizar los requerimientos de información** asociados a la gestión de SST y PESV, identificando las principales entidades, atributos, reglas de negocio y relaciones necesarias para el sistema.
2. **Interpretar y documentar el modelo entidad-relación** propuesto para la plataforma, identificando entidades principales, entidades de parametrización y relaciones entre los diferentes componentes.
3. **Diseñar un modelo de datos multi-tenant** que permita almacenar información correspondiente a múltiples organizaciones manteniendo la independencia lógica de los datos.
4. **Aplicar técnicas de normalización** para disminuir la redundancia y garantizar consistencia e integridad en la información almacenada.
5. **Implementar el modelo físico en PostgreSQL**, utilizando tablas, claves primarias, claves foráneas, restricciones y tipos de datos adecuados.
6. **Implementar operaciones CRUD** mediante instrucciones SQL para la gestión de organizaciones, personas, cargos, módulos, plantillas, formatos y evaluaciones.
7. **Construir consultas SQL** que permitan recuperar y analizar información relacionada con los sistemas SST y PESV.
8. **Implementar consultas utilizando JOIN**, subconsultas, funciones de agregación, agrupamiento y expresiones condicionales.
9. **Diseñar vistas y vistas materializadas** orientadas a la generación de indicadores y reportes de seguimiento.
10. **Implementar funciones y procedimientos almacenados en PL/pgSQL** que automaticen operaciones relacionadas con la administración de la información.
11. **Implementar triggers** que permitan controlar procesos automáticos de auditoría, actualización o validación de datos.
12. **Diseñar índices** que permitan mejorar el rendimiento de las consultas utilizadas con mayor frecuencia.
13. **Implementar mecanismos de integridad y validación** mediante restricciones como `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK` y `NOT NULL`.
14. **Analizar el funcionamiento del modelo PHVA** dentro de la estructura de datos para identificar el avance de cada organización.
15. **Construir consultas de indicadores** que permitan determinar el porcentaje de cumplimiento documental de una empresa.
16. **Aplicar mecanismos básicos de concurrencia**, analizando el uso de estructuras de bloqueo para evitar la edición simultánea de determinados recursos.
17. **Documentar técnicamente la base de datos**, incluyendo diccionario de datos, relaciones, restricciones y principales consultas.

------

# 5. Alcance del proyecto

El proyecto comprenderá el diseño y construcción de una base de datos PostgreSQL orientada a la administración de información de una plataforma SST/PESV.

El sistema deberá manejar, como mínimo, los siguientes componentes:

| Componente            | Función                                                      |
| --------------------- | ------------------------------------------------------------ |
| Empresas              | Administrar las organizaciones registradas                   |
| Personas              | Gestionar usuarios o trabajadores asociados a cada empresa   |
| Cargos                | Definir cargos dentro de las organizaciones                  |
| Sistemas SST          | Configurar sistemas habilitados para cada organización       |
| Módulos               | Organizar los componentes funcionales del sistema            |
| Etapas PHVA           | Clasificar procesos según Planear, Hacer, Verificar y Actuar |
| Plantillas            | Gestionar documentos base                                    |
| Formatos              | Definir formatos asociados a módulos                         |
| Evaluaciones          | Registrar instrumentos o plantillas de evaluación            |
| Ubicación geográfica  | Administrar países, departamentos y municipios               |
| Bloqueos              | Controlar la edición simultánea de recursos                  |
| Indicadores           | Determinar nivel de avance y cumplimiento                    |
| Vistas materializadas | Facilitar consultas consolidadas                             |

# Consultas

## 1. Consultas SQL básicas

Estas consultas permiten evaluar el manejo de `SELECT`, `WHERE`, `ORDER BY`, `DISTINCT`, operadores relacionales, operadores lógicos, `LIKE`, `IN`, `BETWEEN`, `IS NULL`, funciones básicas y limitación de resultados.

| N.º  | Enunciado                                                    |
| ---- | ------------------------------------------------------------ |
| 1    | El estudiante deberá consultar todos los registros almacenados en la tabla `tenants`, mostrando la información disponible de cada organización registrada en el sistema. |
| 2    | El estudiante deberá consultar el nombre, correo de contacto y teléfono de todas las organizaciones registradas en la tabla `tenants`. |
| 3    | El estudiante deberá listar las personas registradas en la tabla `persons`, mostrando sus nombres, apellidos y correo electrónico. |
| 4    | El estudiante deberá consultar las personas cuyo estado se encuentre activo dentro de la plataforma. |
| 5    | El estudiante deberá obtener las organizaciones cuyo nombre contenga una determinada palabra proporcionada como criterio de búsqueda. |
| 6    | El estudiante deberá listar todos los países almacenados en la tabla `countries`, ordenándolos alfabéticamente por nombre. |
| 7    | El estudiante deberá consultar los departamentos o regiones pertenecientes a un país determinado. |
| 8    | El estudiante deberá listar los municipios o ciudades correspondientes a un departamento o región específica. |
| 9    | El estudiante deberá consultar todos los cargos registrados en la tabla `positions`, ordenándolos por descripción. |
| 10   | El estudiante deberá consultar las personas que pertenezcan a una organización determinada mediante su identificador `tenant_id`. |
| 11   | El estudiante deberá obtener las organizaciones que actualmente se encuentren habilitadas o activas dentro del sistema. |
| 12   | El estudiante deberá identificar las organizaciones que hayan sido registradas dentro de un período determinado utilizando la fecha de creación. |
| 13   | El estudiante deberá listar los diferentes tamaños de empresa almacenados en la tabla `tenant_sizes`. |
| 14   | El estudiante deberá consultar los diferentes tipos de sistemas SST registrados en la tabla `type_system_sst`. |
| 15   | El estudiante deberá listar los módulos registrados en el sistema mostrando su título, descripción y orden de presentación. |

## 2. Consultas SQL intermedias

Estas consultas incorporan `INNER JOIN`, `LEFT JOIN`, funciones agregadas, `GROUP BY`, `HAVING`, expresiones condicionales y consultas que relacionan varias entidades.

| N.º  | Enunciado                                                    |
| ---- | ------------------------------------------------------------ |
| 1    | El estudiante deberá consultar todas las personas registradas, mostrando el nombre completo de la persona y el nombre de la organización a la cual pertenece. |
| 2    | El estudiante deberá consultar cada persona junto con el cargo que desempeña dentro de su organización. |
| 3    | El estudiante deberá mostrar cada organización junto con el tamaño de empresa que tiene asignado. |
| 4    | El estudiante deberá consultar cada organización mostrando la ciudad, departamento o región y país donde se encuentra registrada. |
| 5    | El estudiante deberá determinar cuántas personas se encuentran registradas en cada organización. |
| 6    | El estudiante deberá identificar las organizaciones que tengan más de una cantidad determinada de personas registradas. |
| 7    | El estudiante deberá consultar los módulos habilitados para cada organización mediante la relación existente en `tenant_modules`. |
| 8    | El estudiante deberá determinar cuántos módulos tiene habilitados cada organización. |
| 9    | El estudiante deberá consultar los sistemas SST habilitados para cada organización utilizando las tablas `tenantsystems` y `type_system_sst`. |
| 10   | El estudiante deberá mostrar los módulos existentes junto con el sistema SST al cual pertenecen. |
| 11   | El estudiante deberá consultar los formatos registrados en `formats_sst`, mostrando el módulo al cual pertenece cada formato. |
| 12   | El estudiante deberá determinar cuántos formatos se encuentran asociados a cada módulo. |
| 13   | El estudiante deberá consultar las plantillas asignadas a cada organización mediante la tabla `tenanttemplates`. |
| 14   | El estudiante deberá mostrar cada plantilla asignada indicando la organización, el sistema SST y la etapa PHVA relacionada. |
| 15   | El estudiante deberá determinar cuántas plantillas tiene asignada cada organización. |
| 16   | El estudiante deberá consultar las organizaciones que actualmente no tengan personas registradas utilizando una combinación externa entre `tenants` y `persons`. |
| 17   | El estudiante deberá identificar los módulos que todavía no hayan sido asignados a ninguna organización. |
| 18   | El estudiante deberá consultar las etapas PHVA mostrando el número de plantillas que se encuentran asociadas a cada una. |
| 19   | El estudiante deberá determinar cuántas organizaciones se encuentran registradas en cada municipio o ciudad. |
| 20   | El estudiante deberá consultar los cargos existentes en cada organización y determinar cuántas personas ocupan cada cargo. |

## 3. Consultas SQL avanzadas

Estas consultas permiten trabajar subconsultas, CTE, funciones de ventana, agregaciones condicionales, vistas, vistas materializadas y análisis de información.

| N.º  | Enunciado                                                    |
| ---- | ------------------------------------------------------------ |
| 1    | El estudiante deberá identificar la organización que tenga la mayor cantidad de personas registradas, mostrando el nombre de la organización y el número total de personas asociadas. |
| 2    | El estudiante deberá consultar las organizaciones cuya cantidad de personas registradas sea superior al promedio general de personas por organización. |
| 3    | El estudiante deberá identificar las organizaciones que tengan habilitados todos los módulos existentes para un sistema SST determinado. |
| 4    | El estudiante deberá determinar las organizaciones que tengan al menos un módulo configurado pero que todavía no tengan plantillas asignadas. |
| 5    | El estudiante deberá consultar las organizaciones que tengan plantillas asociadas a todas las etapas PHVA disponibles en el sistema. |
| 6    | El estudiante deberá calcular la cantidad de plantillas asignadas a cada organización discriminadas por etapa PHVA. |
| 7    | El estudiante deberá construir una consulta que presente en columnas independientes la cantidad de plantillas correspondientes a Planear, Hacer, Verificar y Actuar para cada organización. |
| 8    | El estudiante deberá determinar el porcentaje que representa cada etapa PHVA sobre el total de plantillas asignadas a una organización. |
| 9    | El estudiante deberá identificar la etapa PHVA que tenga la mayor cantidad de plantillas asignadas dentro de cada organización. |
| 10   | El estudiante deberá calcular el porcentaje de documentos finalizados frente al total de documentos asociados a cada organización utilizando la información disponible en las vistas de resumen. |
| 11   | El estudiante deberá determinar las organizaciones cuyo porcentaje de cumplimiento documental se encuentre por debajo del promedio general del sistema. |
| 12   | El estudiante deberá clasificar las organizaciones según su porcentaje de cumplimiento, estableciendo categorías como bajo, medio y alto mediante una expresión `CASE`. |
| 13   | El estudiante deberá generar un ranking de organizaciones de acuerdo con su porcentaje de cumplimiento documental utilizando funciones de ventana. |
| 14   | El estudiante deberá mostrar para cada organización su porcentaje de cumplimiento y la diferencia existente respecto al promedio general de cumplimiento. |
| 15   | El estudiante deberá determinar la cantidad acumulada de documentos finalizados por organización utilizando una función de ventana. |
| 16   | El estudiante deberá identificar las organizaciones que compartan el mismo municipio pero tengan diferente tamaño empresarial. |
| 17   | El estudiante deberá encontrar las personas cuyo cargo sea utilizado por más personas que el promedio de ocupación de los cargos dentro de su organización. |
| 18   | El estudiante deberá utilizar una expresión común de tabla, `CTE`, para calcular inicialmente la cantidad de personas por organización y posteriormente seleccionar únicamente las organizaciones que superen el promedio. |
| 19   | El estudiante deberá utilizar un `CTE` para consolidar la cantidad de módulos, plantillas y personas correspondientes a cada organización. |
| 20   | El estudiante deberá determinar las organizaciones que no tengan configurada alguna etapa PHVA requerida dentro de sus plantillas. |
| 21   | El estudiante deberá consultar la última fecha de actualización registrada para cada organización considerando sus plantillas asociadas. |
| 22   | El estudiante deberá determinar cuáles organizaciones presentan registros documentales pendientes utilizando las vistas `vm_template_pesv_docs_summary` y `vm_template_sst_docs_summary`. |
| 23   | El estudiante deberá generar un informe consolidado que muestre por organización el total de documentos, documentos finalizados, documentos en borrador, documentos no iniciados, documentos pendientes y porcentaje de cumplimiento. |
| 24   | El estudiante deberá comparar el porcentaje de cumplimiento SST y PESV de cada organización, identificando aquellas en las cuales exista una diferencia superior a un valor establecido. |
| 25   | El estudiante deberá construir una vista que consolide la cantidad de personas, módulos, plantillas y sistemas habilitados para cada organización. |

## 4. Consultas orientadas a vistas y vistas materializadas

Esta sección puede considerarse parte del nivel avanzado.

| N.º  | Enunciado                                                    |
| ---- | ------------------------------------------------------------ |
| 1    | El estudiante deberá crear una vista denominada `vw_tenant_persons` que permita consultar las organizaciones junto con sus personas y cargos asociados. |
| 2    | El estudiante deberá crear una vista que consolide la información geográfica de las organizaciones incluyendo municipio, departamento o región y país. |
| 3    | El estudiante deberá crear una vista que muestre los módulos habilitados para cada organización y el sistema SST al cual pertenecen. |
| 4    | El estudiante deberá crear una vista que presente la cantidad total de plantillas asociadas a cada organización y etapa PHVA. |
| 5    | El estudiante deberá crear una vista que permita consultar el total de personas existentes por organización y cargo. |
| 6    | El estudiante deberá crear una vista materializada que consolide el número total de documentos, documentos finalizados, documentos pendientes y porcentaje de cumplimiento por organización. |
| 7    | El estudiante deberá actualizar una vista materializada mediante `REFRESH MATERIALIZED VIEW` y verificar que los valores consolidados reflejen los últimos cambios realizados en las tablas relacionadas. |
| 8    | El estudiante deberá analizar qué columnas de la vista materializada deberían contar con índices para optimizar las consultas de seguimiento por organización. |

## 5. Procedimientos almacenados

En esta sección el estudiante deberá utilizar `PL/pgSQL`, parámetros, variables, estructuras de control, validaciones, manejo de excepciones y operaciones transaccionales.

| N.º  | Enunciado                                                    |
| ---- | ------------------------------------------------------------ |
| 1    | El estudiante deberá desarrollar un procedimiento almacenado que permita registrar una nueva organización, validando previamente que no exista otra organización con los mismos datos de identificación definidos por el sistema. |
| 2    | El estudiante deberá desarrollar un procedimiento almacenado que permita registrar una nueva persona y asociarla a una organización y a un cargo determinado. |
| 3    | El estudiante deberá desarrollar un procedimiento almacenado que permita cambiar el estado de una organización entre activa e inactiva. |
| 4    | El estudiante deberá desarrollar un procedimiento almacenado que permita asignar un módulo determinado a una organización evitando asignaciones duplicadas. |
| 5    | El estudiante deberá desarrollar un procedimiento almacenado que permita habilitar un sistema SST para una organización determinada. |
| 6    | El estudiante deberá desarrollar un procedimiento almacenado que permita asignar una plantilla a una organización indicando sistema, etapa PHVA y formato correspondiente. |
| 7    | El estudiante deberá desarrollar un procedimiento almacenado que permita cambiar el cargo de una persona dentro de una organización. |
| 8    | El estudiante deberá desarrollar un procedimiento almacenado que permita trasladar una persona de una organización a otra, actualizando las relaciones necesarias. |
| 9    | El estudiante deberá desarrollar un procedimiento almacenado que permita deshabilitar todos los módulos asociados a una organización que haya sido marcada como inactiva. |
| 10   | El estudiante deberá desarrollar un procedimiento almacenado que permita eliminar de manera controlada una asignación de módulo, validando previamente que no existan registros dependientes que impidan la operación. |
| 11   | El estudiante deberá desarrollar un procedimiento almacenado que determine el número total de plantillas asociadas a una organización y muestre el resultado mediante `RAISE NOTICE`. |
| 12   | El estudiante deberá desarrollar un procedimiento almacenado que determine el porcentaje de cumplimiento documental de una organización a partir de sus documentos finalizados y pendientes. |
| 13   | El estudiante deberá desarrollar un procedimiento almacenado que reciba una organización y una etapa PHVA y determine la cantidad de documentos correspondientes a dicha etapa. |
| 14   | El estudiante deberá desarrollar un procedimiento almacenado que permita modificar simultáneamente los datos de contacto de una organización y registre la fecha de actualización correspondiente. |
| 15   | El estudiante deberá implementar manejo de excepciones dentro de un procedimiento encargado de asignar plantillas, de manera que cualquier error producido durante la operación pueda ser controlado adecuadamente. |

## 6. Funciones almacenadas

Conviene incorporar funciones además de procedimientos para que el estudiante identifique las diferencias entre ambos objetos de PostgreSQL.

| N.º  | Enunciado                                                    |
| ---- | ------------------------------------------------------------ |
| 1    | El estudiante deberá implementar una función que reciba el identificador de una organización y retorne la cantidad total de personas asociadas. |
| 2    | El estudiante deberá implementar una función que reciba el identificador de una organización y retorne su porcentaje de cumplimiento documental. |
| 3    | El estudiante deberá implementar una función que determine si una organización tiene habilitado un módulo específico y retorne un valor booleano. |
| 4    | El estudiante deberá implementar una función que reciba el identificador de una persona y retorne su nombre completo. |
| 5    | El estudiante deberá implementar una función que retorne la cantidad de plantillas existentes para una organización y una etapa PHVA determinada. |
| 6    | El estudiante deberá implementar una función tabular que retorne todos los módulos habilitados para una organización. |
| 7    | El estudiante deberá implementar una función tabular que retorne las personas pertenecientes a una organización junto con sus respectivos cargos. |
| 8    | El estudiante deberá implementar una función que clasifique el nivel de cumplimiento de una organización como bajo, medio o alto según el porcentaje calculado. |

## 7. Triggers

Estos ejercicios permiten trabajar automatización, integridad, auditoría y reglas de negocio.

| N.º  | Enunciado                                                    |
| ---- | ------------------------------------------------------------ |
| 1    | El estudiante deberá implementar un trigger que actualice automáticamente el campo `updated_at` cada vez que se modifique un registro de la tabla `tenants`. |
| 2    | El estudiante deberá implementar un trigger que actualice automáticamente el campo `updated_at` cuando se modifique información de una persona. |
| 3    | El estudiante deberá implementar un trigger que impida registrar una persona en una organización que se encuentre inactiva. |
| 4    | El estudiante deberá implementar un trigger que impida asignar un módulo a una organización cuando dicho módulo ya se encuentre previamente asignado. |
| 5    | El estudiante deberá implementar un trigger que impida asignar plantillas a organizaciones cuyo estado se encuentre inactivo. |
| 6    | El estudiante deberá implementar un trigger que valide que una persona únicamente pueda ser asociada a un cargo perteneciente a la misma organización. |
| 7    | El estudiante deberá implementar un trigger que registre automáticamente la fecha de actualización cuando se produzca una modificación en una plantilla asignada a una organización. |
| 8    | El estudiante deberá implementar un trigger que impida eliminar una organización cuando todavía existan personas asociadas a ella. |
| 9    | El estudiante deberá implementar un trigger que impida eliminar un sistema SST cuando existan organizaciones que lo estén utilizando. |
| 10   | El estudiante deberá implementar un trigger que impida eliminar un módulo cuando dicho módulo esté asignado a una o más organizaciones. |
| 11   | El estudiante deberá implementar un trigger que valide que el porcentaje de cumplimiento calculado para una organización permanezca dentro del rango comprendido entre 0 y 100. |
| 12   | El estudiante deberá implementar un trigger que registre en una tabla de auditoría cualquier modificación realizada sobre los datos principales de una organización. |
| 13   | El estudiante deberá implementar un trigger de auditoría que almacene el valor anterior y el nuevo valor cuando se modifique el estado de una organización. |
| 14   | El estudiante deberá implementar un trigger que registre la fecha y el usuario responsable cuando una plantilla sea modificada. |
| 15   | El estudiante deberá implementar un trigger que elimine o marque como inactivos los bloqueos de edición vencidos almacenados en `editing_locks`. |