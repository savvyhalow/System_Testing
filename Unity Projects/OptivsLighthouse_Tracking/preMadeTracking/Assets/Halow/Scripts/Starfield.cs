using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Starfield : MonoBehaviour {

    // Create the Particle system variables 
    private ParticleSystem particle_System;
    private ParticleSystem.Particle[] star;
    public SphereCollider particle_Collider;

    // Set max number of stars, size, and distance from camera
    public int max_number_Stars = 6000;
    public float star_Size = 0.33f;

    //Set max and min star distance
    public float max_star_Distance = 50.0f;
    //public float min_star_Distance = 50.0f;
    //public float random_Position;

    
	// Use this for initialization
	void Start ()
    {

        ParticleSystem particle_System = GetComponent<ParticleSystem>();
        var star_Collision = particle_System.collision;
        star_Collision.enabled = true;
        star_Collision.type = ParticleSystemCollisionType.Planes;
        star_Collision.mode = ParticleSystemCollisionMode.Collision3D;


        Create_Starfield();
    }

    private void Create_Starfield()
    {

        star = new ParticleSystem.Particle[max_number_Stars];

        



        for (int i = 0; i < max_number_Stars; i++)
        {

            // Set distance to random points in sphere with min distance from camera
            //star_Field[i].position = new Vector3(1, 1, 1);
            //random_Position = Random.Range(min_star_Distance, max_star_Distance);
            //star[i].position = new Vector3(random_Position,  random_Position, random_Position);
            //star[i].position = Random.insideUnitSphere * random_Position;

            //random_Position = Random.Range(min_star_Distance, max_star_Distance);
            //star[i].position = Random.insideUnitSphere * random_Position;

            star[i].position = Random.onUnitSphere * max_star_Distance;



            // Set color and size of all stars
            star[i].startColor = Color.white;
            star[i].startSize = star_Size;

        }

        particle_System = GetComponent<ParticleSystem>();
        particle_System.SetParticles(star, star.Length);

    }


    // Update is called once per frame
    void Update ()
    {
        var star_Collision = particle_System.collision;
        star_Collision.lifetimeLoss = 1.0f;
        particle_System = GetComponent<ParticleSystem>();
        particle_System.SetParticles(star, star.Length);

    }
}
