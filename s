

---------- Forwarded message ---------
From: Siddhesh Harwande <siddhesh.harwande25@sakec.ac.in>
Date: Sat, 24 Jan 2026, 00:58
Subject:
To: <sargam.gupta25@sakec.ac.in>


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#ifdef _WIN32
    #include <windows.h>
    #define CLEAR() system("cls")
    #define SLEEP(x) Sleep((x)*1000)
#else
    #include <unistd.h>
    #define CLEAR() system("clear")
    #define SLEEP(x) sleep(x)
#endif

#define MAX_SATS 20
#define MAX_USERS 200
#define MAX_ALERTS 1000
#define SIM_DURATION 180
#define FAILURE_PROB 5
#define RSSI_HISTORY 5
#define EARTH_RADIUS 6371.0  // in km
#define ORBIT_HEIGHT_MIN 400.0
#define ORBIT_HEIGHT_MAX 2000.0

/* ================= STRUCTURES ================= */
typedef struct {
    int id;
    float x;          // Position angle (0-360)
    float dist;       // Distance from Earth station (km)
    float rssi;       // Signal strength
    float snr;
    float temp;
    float reliability;
    float score;
    int users;
    int max_users;
    int uptime;
    int fails;
    int health;
    float rssi_hist[RSSI_HISTORY];
} Satellite;

typedef struct {
    char level[12];
    char msg[140];
    int timestamp;
} Alert;

/* ================= GLOBALS ================= */
Satellite sats[MAX_SATS];
Alert alerts[MAX_ALERTS];
int alert_count = 0;
int system_time = 0;
int active_sat = -1;
float space_weather = 1.0;

/* ============== ALERT SYSTEM ============== */
void raise_alert(const char *level, const char *msg) {
    if (alert_count >= MAX_ALERTS) return;

    strcpy(alerts[alert_count].level, level);
    strcpy(alerts[alert_count].msg, msg);
    alerts[alert_count].timestamp = system_time;
    alert_count++;

    FILE *log = fopen("orbit_latch.log", "a");
    if (log) {
        fprintf(log, "[%04ds] %-10s %s\n", system_time, level, msg);
        fclose(log);
    }
}

/* ================= CALCULATIONS ================= */
float calc_distance(float angle) {
    // Convert orbital angle to distance from ground station (simplified)
    float orbit_radius = EARTH_RADIUS + ORBIT_HEIGHT_MIN + (rand() % (int)(ORBIT_HEIGHT_MAX - ORBIT_HEIGHT_MIN));
    return orbit_radius * fabs(cos(angle)); // km
}

float calc_rssi(float dist) {
    float r = 1200.0f / dist; // Simple path-loss model
    r *= space_weather;
    return (r > 100) ? 100 : r;
}

float predict_rssi(int i) {
    return (sats[i].rssi_hist[0] + sats[i].rssi_hist[RSSI_HISTORY-1]) / 2.0f;
}

/* ================= INITIALIZATION ================= */
void init_sats() {
    for (int i = 0; i < MAX_SATS; i++) {
        sats[i].id = 700 + i;
        sats[i].x = ((float)rand() / RAND_MAX) * 2 * M_PI; // random angle
        sats[i].users = 0;
        sats[i].max_users = MAX_USERS;
        sats[i].uptime = 0;
        sats[i].fails = 0;
        sats[i].health = 1;
        sats[i].temp = 25.0f + (rand() % 10); // realistic start temp
        sats[i].reliability = 1.0f;

        sats[i].dist = calc_distance(sats[i].x);
        sats[i].rssi = calc_rssi(sats[i].dist);

        for (int j = 0; j < RSSI_HISTORY; j++)
            sats[i].rssi_hist[j] = sats[i].rssi;

        sats[i].score = sats[i].rssi;
    }
}

/* ================= UPDATE SATELLITES ================= */
void update_sats() {
    // Random space weather change
    space_weather = (rand() % 100 < 20) ? 0.8f : 1.0f;

    for (int i = 0; i < MAX_SATS; i++) {
        if (!sats[i].health) continue;

        sats[i].x += 0.05f; // orbit movement
        if (sats[i].x > 2*M_PI) sats[i].x -= 2*M_PI;

        sats[i].dist = calc_distance(sats[i].x);
        sats[i].rssi = calc_rssi(sats[i].dist);
        sats[i].snr = sats[i].rssi / 3.0f;

        memmove(&sats[i].rssi_hist[0], &sats[i].rssi_hist[1], sizeof(float) * (RSSI_HISTORY -1));
        sats[i].rssi_hist[RSSI_HISTORY-1] = sats[i].rssi;

        sats[i].temp += sats[i].rssi * 0.005f; // heat from signal

        if (sats[i].temp > 80) {
            sats[i].health = 0;
            sats[i].users = 0;
            raise_alert("CRITICAL", "Thermal overload detected");
        }

        if (rand() % 100 < FAILURE_PROB) {
            sats[i].health = 0;
            sats[i].users = 0;
            sats[i].fails++;
            sats[i].reliability -= 0.1f;
            if (sats[i].reliability < 0.1f) sats[i].reliability = 0.1f;

            raise_alert("CRITICAL", "Satellite failure occurred");

            if (active_sat == i) {
                active_sat = -1;
                raise_alert("EMERGENCY", "Active satellite lost");
            }
        }
    }
}

/* ================= SATELLITE SELECTION ================= */
int find_best_sat() {
    int best = -1;
    float best_score = -1;

    for (int i = 0; i < MAX_SATS; i++) {
        if (!sats[i].health || sats[i].users >= sats[i].max_users) continue;

        float load = (float)sats[i].users / sats[i].max_users;
        float predicted = predict_rssi(i);
        sats[i].score = predicted * sats[i].reliability / (1 + load);

        if (sats[i].score > best_score) {
            best_score = sats[i].score;
            best = i;
        }
    }
    return best;
}

/* ================= CONNECTION MANAGER ================= */
void manage_connection() {
    if (active_sat != -1) {
        if (!sats[active_sat].health || predict_rssi(active_sat) < 35) {
            if (sats[active_sat].users > 0) sats[active_sat].users--;
            raise_alert("INFO", "Predictive handover triggered");
            active_sat = -1;
        } else sats[active_sat].uptime++;
    }

    if (active_sat == -1) {
        int next = find_best_sat();
        if (next != -1) {
            active_sat = next;
            sats[next].users++;
            sats[next].uptime = 0;
            raise_alert("INFO", "User connected to satellite");
        } else {
            raise_alert("WARNING", "No satellite available");
        }
    }
}

/* ================= RENDER ================= */
void render() {
    int info=0,warn=0,crit=0,emerg=0;
    int alive=0;
    float avg_rssi=0;

    CLEAR();
    printf("ORBIT-LATCH v4.0 :: SATELLITE HANDOVER SIMULATION\n");
    printf("TIME %02d:%02d | SPACE WEATHER %.1fx\n\n", system_time/60, system_time%60, space_weather);

    printf("ID   STATE      DIST(km) RSSI LOAD SNR TEMP REL UP FAIL SCORE\n");
    printf("----------------------------------------------------------------\n");

    for (int i = 0; i < MAX_SATS; i++) {
        char state[12] = "STANDBY";
        if (!sats[i].health) strcpy(state, "FAILED");
        else if (i == active_sat) strcpy(state, "CONNECTED");

        if (sats[i].health) {
            avg_rssi += sats[i].rssi;
            alive++;
        }

        printf("%-4d %-10s %8.1f %5.1f %4d%% %4.1f %4.1f %.2f %2d %4d %6.1f\n",
            sats[i].id, state, sats[i].dist, sats[i].rssi,
            (sats[i].users*100)/MAX_USERS, sats[i].snr,
            sats[i].temp, sats[i].reliability,
            sats[i].uptime, sats[i].fails,
            sats[i].score);
    }

    avg_rssi = alive ? avg_rssi / alive : 0;

    printf("\nALERT HISTORY (All):\n");
    printf("--------------------\n");
    for (int i = 0; i < alert_count; i++) {
        printf("[%04ds] %-10s %s\n", alerts[i].timestamp, alerts[i].level, alerts[i].msg);
        if (!strcmp(alerts[i].level,"INFO")) info++;
        else if (!strcmp(alerts[i].level,"WARNING")) warn++;
        else if (!strcmp(alerts[i].level,"CRITICAL")) crit++;
        else if (!strcmp(alerts[i].level,"EMERGENCY")) emerg++;
    }

    printf("\nALERT COUNT: INFO:%d WARN:%d CRIT:%d EMERG:%d\n", info,warn,crit,emerg);
    printf("Operational Satellites: %d/%d | Avg RSSI %.1f\n", alive, MAX_SATS, avg_rssi);
}

/* ================= MAIN ================= */
int main() {
    srand(time(NULL));
    init_sats();

    printf("Starting ORBIT-LATCH v4.0 Simulation...\n");
    SLEEP(2);

    while (system_time < SIM_DURATION) {
        system_time++;
        update_sats();
        manage_connection();
        render();
        SLEEP(1);
    }

    printf("\n=== SIMULATION COMPLETE ===\n");
    printf("Total alerts: %d\n", alert_count);
    return 0;
}

Please don't print this email, unless you need to.
Vision:
To become a globally recognized institution offering quality education and enhancing professional standards.
Mission:
To impart high quality technical education to the students by providing an excellent academic environment, well-equipped laboratories and training through the motivated teachers.
