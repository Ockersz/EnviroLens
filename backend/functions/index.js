const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Return waste credits and area rank (dummy values)
exports.getUserStats = onRequest((req, res) => {

    const dummyData = {
        credits: 480,
        areaRank: 12
    };

    res.status(200).json(dummyData);
});

exports.getTopLeaderboard = onRequest((req, res) => {
    const dummyData = {
        leaders: [
            { name: "Alice", score: 1000, rank: 1 },
            { name: "Bob", score: 980, rank: 2 },
            { name: "Charlie", score: 950, rank: 3 }
        ]
    };
    res.status(200).json(dummyData);
});


exports.getBinDisposalGuidlines = onRequest((req, res) => {
    //check for the bin type
    const binType = req.query.type;

    if (!binType) {
        return res.status(400).send("Bin type is required");
    }

    // Dummy data for bin disposal guidelines
    const guidelines = {
        organic: [
            {
                id: 1,
                title: "Separate Properly",
                description: "Keep organic waste apart from plastics, metals, and non-biodegradables."
            },
            {
                id: 2,
                title: "Compost at Home",
                description: "Convert food scraps and garden waste into nutrient-rich compost."
            },
            {
                id: 3,
                title: "Use Collection Services",
                description: "Dispose of organic waste in designated community compost bins."
            },
            {
                id: 4,
                title: "Avoid Contamination",
                description: "Don't mix organic waste with plastic or hazardous materials."
            },
            {
                id: 5,
                title: "No Processed Foods",
                description: "Avoid adding meat, dairy, or oily foods into home compost."
            },
            {
                id: 6,
                title: "Shred Large Waste",
                description: "Break down large pieces to accelerate composting."
            },
            {
                id: 7,
                title: "Cover Compost",
                description: "Keep compost piles covered to retain moisture and avoid pests."
            }
        ],
        paper: [
            {
                id: 1,
                title: "Recycle Clean Paper",
                description: "Only recycle dry, clean paper products like office paper or newspapers."
            },
            {
                id: 2,
                title: "Avoid Coated Paper",
                description: "Do not recycle laminated, waxed, or foil-lined papers."
            },
            {
                id: 3,
                title: "Flatten Boxes",
                description: "Flatten cartons and boxes to save bin space."
            },
            {
                id: 4,
                title: "No Food Contamination",
                description: "Pizza boxes and food-soiled paper should not be recycled."
            },
            {
                id: 5,
                title: "Remove Staples",
                description: "Remove clips or bindings from paper before recycling."
            },
            {
                id: 6,
                title: "Recycle Envelopes",
                description: "Even windowed envelopes can usually be recycled."
            },
            {
                id: 7,
                title: "Avoid Wet Paper",
                description: "Wet paper loses its recyclability. Keep it dry."
            }
        ],
        glass_plastic: [
            {
                id: 1,
                title: "Rinse Containers",
                description: "Wash out bottles and jars before recycling."
            },
            {
                id: 2,
                title: "Sort by Type",
                description: "Some areas require sorting by glass or plastic type."
            },
            {
                id: 3,
                title: "Remove Caps",
                description: "Plastic and metal caps should be removed from bottles."
            },
            {
                id: 4,
                title: "Do Not Recycle Broken Glass",
                description: "Broken glass should be disposed of safely, not recycled."
            },
            {
                id: 5,
                title: "Avoid Plastic Bags",
                description: "Plastic bags clog machines and must be recycled separately."
            },
            {
                id: 6,
                title: "Check Labels",
                description: "Look for recycling symbols to determine acceptability."
            },
            {
                id: 7,
                title: "Reuse When Possible",
                description: "Consider reusing jars and containers around the home."
            },
            {
                id: 8,
                title: "Avoid Colored Glass",
                description: "Colored glass often has limited recyclability."
            }
        ],
        miscellaneous: [
            {
                id: 1,
                title: "Check Local Rules",
                description: "Local councils may have special instructions for unique waste types."
            },
            {
                id: 2,
                title: "Electronic Waste",
                description: "Dispose of batteries, phones, and gadgets at e-waste centers."
            },
            {
                id: 3,
                title: "Hazardous Waste",
                description: "Items like paint, chemicals, and cleaners need special handling."
            },
            {
                id: 4,
                title: "Clothing & Textiles",
                description: "Donate usable clothes or recycle textiles at designated centers."
            },
            {
                id: 5,
                title: "Furniture & Bulk Items",
                description: "Schedule a pickup or drop-off with your local waste services."
            },
            {
                id: 6,
                title: "Ceramics & China",
                description: "These do not go in glass bins. Dispose of with general waste."
            },
            {
                id: 7,
                title: "Medical Waste",
                description: "Needles, masks, and medicine must go to health-safe collection points."
            }
        ]
    };


    // Check if the bin type exists in the guidelines
    if (!guidelines[binType]) {
        return res.status(404).send("No guidelines found for this bin type");
    }

    // Return the guidelines for the specified bin type
    res.status(200).json(guidelines[binType]);
});


exports.getDisposalCenters = onRequest(async (req, res) => {
    const dummyData = [
        {
            id: "1",
            name: "Colombo Municipal Waste Center",
            latitude: 6.9271,
            longitude: 79.8612,
            acceptedTypes: ["organic", "plastic", "glass"],
            hours: {
                weekday: "8:00 AM - 6:00 PM",
                saturday: "9:00 AM - 4:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "2",
            name: "Borella Recycling Yard",
            latitude: 6.9187,
            longitude: 79.8788,
            acceptedTypes: ["paper", "cardboard"],
            hours: {
                weekday: "9:00 AM - 5:00 PM",
                saturday: "10:00 AM - 2:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "3",
            name: "Wellawatte E-Waste Center",
            latitude: 6.8772,
            longitude: 79.8615,
            acceptedTypes: ["e-waste", "batteries"],
            hours: {
                weekday: "10:00 AM - 6:00 PM",
                saturday: "10:00 AM - 3:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "4",
            name: "Nugegoda Waste Sorting Facility",
            latitude: 6.8723,
            longitude: 79.8865,
            acceptedTypes: ["organic", "glass"],
            hours: {
                weekday: "7:00 AM - 4:00 PM",
                saturday: "8:00 AM - 1:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "5",
            name: "Dehiwala Eco Drop-off",
            latitude: 6.8446,
            longitude: 79.8655,
            acceptedTypes: ["plastic", "paper"],
            hours: {
                weekday: "9:00 AM - 5:30 PM",
                saturday: "9:00 AM - 1:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "6",
            name: "Kollupitiya Green Hub",
            latitude: 6.9167,
            longitude: 79.8486,
            acceptedTypes: ["e-waste", "plastic", "batteries"],
            hours: {
                weekday: "10:00 AM - 6:00 PM",
                saturday: "10:00 AM - 4:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "7",
            name: "Thimbirigasyaya Waste Depot",
            latitude: 6.9028,
            longitude: 79.8723,
            acceptedTypes: ["glass", "organic", "paper"],
            hours: {
                weekday: "8:00 AM - 4:00 PM",
                saturday: "8:00 AM - 12:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "8",
            name: "Rajagiriya Sorting Point",
            latitude: 6.9124,
            longitude: 79.8912,
            acceptedTypes: ["e-waste", "plastic"],
            hours: {
                weekday: "9:30 AM - 6:00 PM",
                saturday: "9:00 AM - 3:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "9",
            name: "Pelawatte Eco Center",
            latitude: 6.8892,
            longitude: 79.9301,
            acceptedTypes: ["organic", "cardboard", "glass"],
            hours: {
                weekday: "7:30 AM - 5:00 PM",
                saturday: "8:00 AM - 2:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "10",
            name: "Battaramulla Central Waste",
            latitude: 6.9021,
            longitude: 79.9183,
            acceptedTypes: ["paper", "plastic", "metal"],
            hours: {
                weekday: "8:30 AM - 5:30 PM",
                saturday: "9:00 AM - 1:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "11",
            name: "Ragama Urban Council Recycling Yard",
            latitude: 7.0272,
            longitude: 79.9483,
            acceptedTypes: ["plastic", "metal", "organic"],
            hours: {
                weekday: "8:00 AM - 5:00 PM",
                saturday: "9:00 AM - 1:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "12",
            name: "Mahabage Community Waste Drop",
            latitude: 7.0085,
            longitude: 79.9260,
            acceptedTypes: ["paper", "glass"],
            hours: {
                weekday: "9:00 AM - 4:00 PM",
                saturday: "9:00 AM - 12:00 PM",
                sunday: "Closed"
            }
        },
        {
            id: "13",
            name: "Dalugama Eco-Friendly Collection Point",
            latitude: 7.0159,
            longitude: 79.9392,
            acceptedTypes: ["e-waste", "batteries", "plastic"],
            hours: {
                weekday: "8:00 AM - 5:30 PM",
                saturday: "9:00 AM - 2:00 PM",
                sunday: "Closed"
            }
        }
    ];


    res.status(200).json(dummyData);
});


exports.getDisposalHistory = onRequest((req, res) => {
    const dummyData = [
        {
            date: "01/03/2025",
            categories: [
                {
                    type: "Organic",
                    weight: 10,
                    iconName: "RCanBrwn"
                },
                {
                    type: "Paper",
                    weight: 12,
                    iconName: "RCanBlu"
                },
                {
                    type: "Glass/plastic",
                    weight: 2,
                    iconName: "RCanGr"
                },
                {
                    type: "Miscellaneous",
                    weight: 1,
                    iconName: "RCanBlck",
                }
            ]
        },
        {
            date: "15/02/2025",
            categories: [
                {
                    type: "Organic",
                    weight: 7,
                    iconName: "RCanBrwn",
                },
                {
                    type: "Plastic",
                    weight: 3,
                    iconName: "RCanGr"
                }
            ]
        }
    ];

    res.status(200).json(dummyData);
});

exports.getSmartBins = onRequest((req, res) => {
    const binsByLocation = [
        {
            location: "Floor 1 - Kitchen",
            bins: [
                { type: "Organic", fillLevel: 100, iconName: "RCanBrwn" },
                { type: "Paper", fillLevel: 51, iconName: "RCanBlu" },
                { type: "Glass/plastic", fillLevel: 10, iconName: "RCanGr" },
                { type: "Miscellaneous", fillLevel: 70, iconName: "RCanBlck" }
            ]
        },
        {
            location: "Outdoor Bins",
            bins: [
                { type: "Organic", fillLevel: 8, iconName: "RCanBrwn" },
                { type: "Paper", fillLevel: 70, iconName: "RCanBlu" },
                { type: "Glass/plastic", fillLevel: 60, iconName: "RCanGr" },
                { type: "Miscellaneous", fillLevel: 48, iconName: "RCanBlck" }
            ]
        }
    ];

    res.status(200).json(binsByLocation);
});

exports.addSmartBin = onRequest((req, res) => {
    if (req.method !== "POST") {
        return res.status(405).send("Method Not Allowed");
    }

    const { code, label } = req.body;

    if (!code || !label) {
        return res.status(400).json({ error: "Missing code or label" });
    }

    // existing data
    const existingBins = [
        {
            location: "Floor 1 - Kitchen",
            bins: [
                { type: "Organic", fillLevel: 100, iconName: "RCanBrwn" },
                { type: "Paper", fillLevel: 51, iconName: "RCanBlu" },
                { type: "Glass/plastic", fillLevel: 10, iconName: "RCanGr" },
                { type: "Miscellaneous", fillLevel: 70, iconName: "RCanBlck" }
            ]
        },
        {
            location: "Outdoor Bins",
            bins: [
                { type: "Organic", fillLevel: 8, iconName: "RCanBrwn" },
                { type: "Paper", fillLevel: 70, iconName: "RCanBlu" },
                { type: "Glass/plastic", fillLevel: 60, iconName: "RCanGr" },
                { type: "Miscellaneous", fillLevel: 48, iconName: "RCanBlck" }
            ]
        }
    ];

    const newBinGroup = {
        location: label,
        bins: [
            { type: "Organic", fillLevel: 0, iconName: "RCanBrwn" },
            { type: "Paper", fillLevel: 0, iconName: "RCanBlu" },
            { type: "Glass/plastic", fillLevel: 0, iconName: "RCanGr" },
            { type: "Miscellaneous", fillLevel: 0, iconName: "RCanBlck" }
        ]
    };

    const allBins = [...existingBins, newBinGroup];

    return res.status(200).json(allBins);
});

exports.getNotifications = onRequest((req, res) => {
    const dummyNotifications = [
        {
            id: 1,
            title: "Disposal Successful",
            description: "Your recent waste disposal at 'Ragama Center' has been recorded successfully.",
            timestamp: "9:42 AM"
        },
        {
            id: 2,
            title: "Bin Full Alert",
            description: "The 'Organic' bin on Floor 1 is full. Please dispose it soon.",
            timestamp: "8:30 AM"
        },
        {
            id: 3,
            title: "New Reward Unlocked",
            description: "You earned 10 Green Points for disposing 5 KG of Paper!",
            timestamp: "Yesterday"
        },
        {
            id: 4,
            title: "Reminder: Collection Tomorrow",
            description: "Scheduled waste collection is tomorrow at 10:00 AM for Outdoor Bins.",
            timestamp: "Yesterday"
        },
        {
            id: 5,
            title: "Welcome to EnviroLens",
            description: "Thanks for joining! Start scanning to track your eco-impact.",
            timestamp: "2 days ago"
        }
    ];

    res.status(200).json(dummyNotifications);
});

