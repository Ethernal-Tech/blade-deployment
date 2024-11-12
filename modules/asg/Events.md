3 Event-a koji se prate:

- AUTOSCALING:EC2_INSTANCE_LAUNCHING (zapravo autoscaling lifecycle hook)
- EC2 Instance State-change Notification (kad god ec2 instanca promeni stanje)
- AUTOSCALING:EC2_INSTANCE_TERMINATING (autoscaling lifecycle hook)

Ponasanje
- EC2_INSTANCE_LAUNCHING upisuje u `aws-launch-succesful` topic i trigeruje xnet-tagger lambda funkciju. Ovaj event je pokrenut od strane ASG i tu mozemo da pravimo razliku da li je instanca vezana za Active gtupu ili warm pool
- EC2 Instance State-change Notification upisuje u `xnet-ec2-running` topic i trigeruje xnet-runner fuknciju. Ova funkcija reaguje na promene stanja instance. U sklopu ovog event-a saznajemo da li je instanca dosla u running stanje, ali nemamo infomracije o tome da li je instanca vezana za autoscaling grupu, da li pripada warm pool ili active. Mimo running, mozemo reagovati na shutting-down, terminating
- EC2_INSTANCE_TERMINATING upisuje u `xnet-terminating` topic i trigeruje xnet-terminating funkciju. Ova funkcija je takodje pokrenuta od strane autoscaling grupe i ukoliko je akcija terminating pokrenuta kroz EC2 konzolu (mi ugasimo masinu) ovaj event se ne trigeruje. U sklopu ovog event-a radimo cleanup


Proces

- Prvo se kreira resurs koji uradi bootstrap i na S3 bucket uploaduje zip koji u sebi sadrzi genesis i fajlovi koji se prosledjuje kao --secrets-config parametar za server komandu
- Posle ovog resursa se kreira autoscaling grupa koja generise EC2_INSTANCE_LAUNCHING eventove. Šalje se upit ka bazi koji uradi update ukoliko je value False
```python
dynamodb.update_item( TableName='Hostnames', ConditionExpression="#EX = :unused",
                                    ExpressionAttributeValues={':used': {'BOOL': True}, ':unused': {'BOOL': False}},
                                    ExpressionAttributeNames={'#EX': 'Exists'},
                                    Key={
                                        'Hostname' : {
                                            'S': "validator-00{}".format(i),
                                            },
                                                        },
                                    UpdateExpression="SET #EX = :used"
                
                                )
```
Nakon ovoga se setuje IP adresa od instance u DNS record i nalepi se vrednost hostname-a (validator-00X.xnet.blade.ethernal.private) na tagove Name i Hostname
- Event Ec2 instance change moze da se desi dok se prethodni event nije završio a možda čak i pre njega. Pizivamo Ec2 API da vidimo da li postoji vrednost za tag Hostname, sve dok je nema, ne mozemo da izvrsimo komandu za pokretanje servisa. POsle toga pokusavamo da izvrsimo komandu za pokretanje servisa. SUmnjam da je prilikom startovanja masine potreban odredjen period kako bi SSM https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html postao spreman da primi komande. Ovaj kod bi mogao da se prebaci u EC2_INSTANCE_LAUNCHING event handling. Tu vec znamo da ima tag jer smo mi ti koji tagujemo, jedino sto iz tog event-a ne znamo je da li je instanca u stanju running
Skripta koja sluzi za pokretanje servisa radi sledece: Poziva instance-metadata da procita vrednost svojih tagova za Hostname i to onda koristi kao parametar dda skine fajl koji sluzi kao uputstvo za pokretanje servisa i config fajl za CloudWatch agenta. Znamo da ce instance-metadata vratiti vrednost za tag Hostname jer pre toga ne izvrsavamo funkciju
- EC2_INSTANCE_TERMINATING se izvrsava kada ASG urati termination instance. Ovde se samo radi update sa bazom da se oslobodi kljuc. Iscita se tag sa instance i na osnovu toga znamo koji kljuc da oslobodimo



