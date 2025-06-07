# PDMIU Project  
## My Green Space  

**Student**: Francesco Pio Rossi  
**Student ID**: 331825  
**Professor**: Cuno Lorenz Klopfenstein  
**Exam Session**: June 2025  

## Application Overview  

**My Green Space** is a Flutter application designed to help users manage their personal home gardens. The app features a plant catalog where users can browse a limited selection of plants and view key information such as a short description, optimal temperature, transplanting period, and more.  

Users can create instances from this catalog to represent their own personal plants. Each personal plant is assigned a unique ID, and users can store specific information for each one — such as its location, a list of irrigation records, personal notes, and photos documenting the plant's growth over time. Additionally, users can maintain a to-do list related to garden care and maintenance.  

## Technical Details  

The app uses the **Riverpod** library for state management. User data is stored in **Supabase**, an online relational database. Supabase's storage feature is also used to save user-uploaded plant photos. For managing the local state — specifically the to-do list — the **shared_preferences** package is utilized.  

 ## Homepage and navigation between different pages
 
 
