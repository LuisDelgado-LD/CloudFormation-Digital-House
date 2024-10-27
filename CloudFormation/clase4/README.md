# Clase 4 
## Ejercicio

crear una plantilla de CloudFormation que cree
- Un bucket S3
- dos instancias EC2 con las siguientes caracteristicas:
	- En alguna zona de disponibilidad de Virginia del norte
	- Con una AMI seleccionada por mi
	- Tipo t2.micro
	- Seleccionar una key existente
	- cambiar el comportamiento del apagado a stop
	- Que no se monitoree la instancia

## Investigación
El profesor entrega junto con la guia los siguientes enlaces de ayuda
- 


## Ejecución
Ya que queria utilizar la herramienta ([Designer](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/working-with-templates-cfn-designer.html)) fue la primera sección que visité e interactue con los distintos bloques que me proveia.

De ese trabajo obtuve un primer template el cual apliqué sin embargo tuve varios errores.

También con el equipo investigamos los templates prediseñados de CloudFormation. Aunque al tener tantas propiedades distintas descartamos la opción en favor del tiempo.

El trabajo con Designer me gustó pero de igual forma tuve que leer la documentación ya que no encontré un listado de todas las opciones del recurso que quería implementar, y en su lugar tenía un cuadro de texto para ir colocandolas manualmente.

Para la zona de disponibilidad (AvailabilityZone) fue fácil, desde la consola de AWS en la parte superior buscar Virginia y ver cuál era su nomenclatura[¹](#Error 1).

En el caso de la AMI(ImageId), con la intención de terminar el trabajo rápido busque directamente desde la consola AWS, en el catalogo a ver si aparecía el código necesario lo cual resultó 

El tipo de instancia (InstanceType) fue el más fácil ya que sabemos con cual trabajamos

Para la key (KeyName) tuve problemas ya que no encontraba donde obtener el dato necesario (string), busqué en [KMS](https://docs.aws.amazon.com/kms/) sin embargo tuve problemas con los permisos de mi cuenta y no pude visualizar muchas de las opciones.
Con esto pensé que no podría hacer el ejercicio. Pero decidí cambiar el enfoque, quizás no pueda crear las llaves pero si se que puedo crear la instancia EC2 y en sus opciones esta la posibilidad de seleccionar una llave existente o crear una nueva.

Efectivamente, al crear la instancia pude crear una nueva llave[²](#Error 4) (ya venía una por defecto) y ese fue el nombre que utilicé para el template

Las propiedades de Monitoring e InstanceInitiatedShutdownBehavior fueron simples ya que tenían pocas opciones de configuración.

Lo siguiente fue aplicar el template, CloudFormation me creo un bucket S3 para almacenar el archivo y aproveché de descargarlo.

Todo el proceso de troubleshooting lo realicé modificando el template descargado y subiéndolo nuevamente

### Error 1
El primer error que cometí fue utilizar el código de la región en donde debería haber utilizado el código de la zona de disponibilidad

#### Solución error 1
Como el profesor comentó durante la clase, las regiones terminan en **número** y las zonas de disponibilidad en **letra**, simplemente agregue una letra al final en cada propiedad de las instancias ec2, ya que sabemos que S3 es un servicio global por lo que se asigna a una region y no una zona de disponibilidad específica.
También sabía que máximo a la fecha una región tiene 6 o 7 zonas de disponibilidad distintas por lo que no utilicé una letra muy alta (a y b solamente)

### Error 2
Utilizar un nombre de bucket que contenia mayúsculas ya que pretendí utilizar la notación camelCase. Según la [información de AWS](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html) solo se pueden utilizar minúsculas, números, puntos y guiones (entre otras reglas).

#### Solución.
Modificar el nombre del recurso en el template y el bucketname. Esto me lleva al siguiente error

### Error 3
El nombre que asigné desde Designer se aplica en varios otros parametros, al modificar el nombre del recurso y del bucket, estos otros parametros apuntaban a elementos inexistentes. 

#### Solución.
Utilicé la opción de reemplazar todo en mi editor de texto, las líneas que se modificaron fueron:

```yaml
c1bucketunicoquepidioelprofedeinfra2024Policy:
	Properties:
		Bucket: c1bucketunicoquepidioelprofedeinfra2024
		PolicyDocument:
			Statement:
				Resource:
				- !GetAtt c1bucketunicoquepidioelprofedeinfra2024.Arn
				- !Sub ${c1bucketunicoquepidioelprofedeinfra2024.Arn}/*
```

### Error 4
Buscar las llaves ssh en KMS.

#### Solución.
La búsqueda de las keys es en mismo servicio EC2.
Adicional, existe un recurso de [CloudFormation](https://docs.aws.amazon.com/es_es/AWSCloudFormation/latest/UserGuide/AWS_EC2.html) que permite crear la llave desde el template 

## Conclusiones

- Si bien el ejercicio se ve simple, es una buena oportunidad para hacer el primer contacto con CloudFormation.
- La opción Designer no resulta tan útil, al menos con ejercicios pequeños, ya que igualmente hay que buscar los parametros
- El ejercicio nos recuerda la importancia de buscar tanto en la documentación como en otros recursos web.
- El ejercicio omite muchas opciones y servicios básicos necesarios para montar una infraestructura productiva, como la VPC, permisos de bucket, grupos de seguridad y tags




