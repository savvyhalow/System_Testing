using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomStarfield : MonoBehaviour
{

    // Main components of the particle system
    private Transform particlePosition;
    private ParticleSystem particle_System;
    private ParticleSystem.Particle[] particle;

    // Determine max number of stars, each particle size, and distance between each one.
    public int max_number_of_Stars = 8000;
    public float star_Size = 0.33f;
    public float star_Distance = 50;

	// Use this for initialization
	void Start ()
    {

        particlePosition = transform;
        CreateStars();
        particle_System = GetComponent<ParticleSystem>();
        particle_System.SetParticles(particle, particle.Length);

    }

    private void CreateStars()
    {
        // Set parameters for each star (particle) with a max total for the system
        particle = new ParticleSystem.Particle[max_number_of_Stars];

        for (int i = 0; i < max_number_of_Stars; i++)
        {
            // Set distance between stars
            particle[i].position = Random.insideUnitSphere * star_Distance + particlePosition.position;

            //Set star color - white
            particle[i].startColor = new Color(1, 1, 1, 1);     
            
            //Set star size
            particle[i].startSize = star_Size;

        }
    }

	
	// Update is called once per frame
	void Update ()
    {
        // Impliment star system
        particle_System = GetComponent<ParticleSystem>();
        particle_System.SetParticles(particle, particle.Length);
               


    }
}
